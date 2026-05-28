// ============================================================================
// IAP SERVICE — In-App Purchase (Google Play Billing / Apple StoreKit)
// ============================================================================
// Compras de coins dentro do app são OBRIGATORIAMENTE feitas via as lojas
// (Google Play Billing no Android, StoreKit no iOS) por exigência das
// políticas de pagamentos digitais. Wolknow/PIX só pode ser usado na web.
//
// Fluxo:
//   1. App chama `loadProducts()` → lista produtos da Play/App Store.
//   2. Usuário escolhe pacote → `buy(productId)` abre o sheet nativo.
//   3. Loja confirma compra → vem `PurchaseDetails` no stream.
//   4. App envia o recibo ao backend (`/credits/iap/verify`) que valida
//      junto ao Google/Apple e credita as coins na conta do usuário.
//   5. App chama `completePurchase()` p/ encerrar a transação na loja.
//
// Idempotência: o backend usa `purchaseId` como chave única — se chegar
// duas vezes, ignora a segunda.
// ============================================================================

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'credits_service.dart';

part 'iap_service.g.dart';

/// IDs dos produtos cadastrados no Google Play Console e App Store Connect.
///
/// IMPORTANTE: os mesmos IDs devem ser cadastrados em:
///   • Google Play Console → Monetizar → Produtos → Produtos no app
///   • App Store Connect → Apps → Compras no app
/// Os preços são definidos NAS LOJAS (não no app), pois cada moeda local
/// tem regra de imposto/conversão diferente.
const Map<String, int> kIapProductCoins = {
  'brawe_coins_83': 83,
  'brawe_coins_416': 416,
  'brawe_coins_2083': 2083,
  'brawe_coins_10416': 10416,
  'brawe_coins_52083': 52083,
  'brawe_coins_260416': 260416,
};

Set<String> get kIapProductIds => kIapProductCoins.keys.toSet();

/// Mapeia o `package_id` interno (mesmo do backend Wolknow) para o productId
/// das lojas. Mantém a abstração consistente com o catálogo do servidor.
const Map<String, String> kPackageIdToIapProductId = {
  'pack_83': 'brawe_coins_83',
  'pack_416': 'brawe_coins_416',
  'pack_2083': 'brawe_coins_2083',
  'pack_10416': 'brawe_coins_10416',
  'pack_52083': 'brawe_coins_52083',
  'pack_260416': 'brawe_coins_260416',
};

/// Resultado da operação `buy()`.
enum IapBuyResult {
  /// Compra finalizada e coins creditadas com sucesso.
  success,

  /// Usuário cancelou o sheet nativo de pagamento.
  cancelled,

  /// Compra pendente (ex: PIX/boleto via Google Play — ainda aguardando pagto).
  pending,

  /// Erro na loja (cartão recusado, sem conexão, produto inválido, etc).
  error,
}

@Riverpod(keepAlive: true)
IapService iapService(Ref ref) {
  return IapService(ref.watch(creditsServiceProvider));
}

class IapService {
  final CreditsService _creditsService;
  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _sub;
  final Map<String, Completer<IapBuyResult>> _pending = {};
  List<ProductDetails> _products = const [];
  bool _initialized = false;
  bool _available = false;

  IapService(this._creditsService);

  bool get isAvailable => _available;
  List<ProductDetails> get products => List.unmodifiable(_products);

  /// Plataforma suporta IAP?
  bool get supportsIap =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Inicializa o listener de compras. Deve ser chamado uma vez na vida
  /// do app (ex: no construtor do provider).
  Future<void> init() async {
    if (_initialized || !supportsIap) return;
    _initialized = true;

    _available = await _iap.isAvailable();
    if (!_available) {
      debugPrint('⚠️  IAP indisponível na loja deste dispositivo');
      return;
    }

    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onDone: () => _sub?.cancel(),
      onError: (Object err, StackTrace st) {
        debugPrint('❌ IAP purchaseStream error: $err');
      },
    );
  }

  /// Busca os produtos cadastrados nas lojas (preço/título/descrição
  /// localizados pela própria loja). Chamar antes de mostrar a UI.
  Future<List<ProductDetails>> loadProducts() async {
    if (!supportsIap || !_available) return const [];
    final response = await _iap.queryProductDetails(kIapProductIds);
    if (response.error != null) {
      debugPrint('❌ IAP queryProductDetails: ${response.error}');
    }
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('⚠️  IAP productIds não cadastrados na loja: '
          '${response.notFoundIDs}');
    }
    _products = response.productDetails;
    return _products;
  }

  /// Inicia o fluxo de compra. Retorna um Future que resolve quando o
  /// recibo é validado no backend (sucesso/erro/pendente) OU o usuário
  /// cancela o sheet.
  Future<IapBuyResult> buy(String productId) async {
    if (!supportsIap || !_available) return IapBuyResult.error;

    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw StateError(
        'Produto IAP "$productId" não foi carregado. '
        'Chame loadProducts() antes de buy().',
      ),
    );

    // Já tem um Completer em andamento p/ esse produto? evita duplicação.
    _pending[productId]?.complete(IapBuyResult.cancelled);
    final completer = Completer<IapBuyResult>();
    _pending[productId] = completer;

    final purchaseParam = PurchaseParam(productDetails: product);

    // Coins são CONSUMABLE (podem ser compradas várias vezes pelo mesmo
    // usuário). NÃO usar buyNonConsumable para isso.
    final ok = await _iap.buyConsumable(
      purchaseParam: purchaseParam,
      autoConsume: true, // Android: consome automaticamente após validar.
    );

    if (!ok) {
      _pending.remove(productId);
      return IapBuyResult.error;
    }

    return completer.future;
  }

  /// Listener invocado pela InAppPurchase a cada update de compra.
  Future<void> _onPurchaseUpdates(List<PurchaseDetails> updates) async {
    for (final purchase in updates) {
      final productId = purchase.productID;
      final completer = _pending[productId];
      bool creditedSuccessfully = false;

      switch (purchase.status) {
        case PurchaseStatus.pending:
          // Pagamento em processamento (ex: PIX na Play). Mantém Completer
          // aguardando até o usuário pagar e a loja confirmar.
          debugPrint('💤 IAP pending: $productId');
          break;

        case PurchaseStatus.canceled:
          debugPrint('🚫 IAP canceled: $productId');
          completer?.complete(IapBuyResult.cancelled);
          _pending.remove(productId);
          break;

        case PurchaseStatus.error:
          debugPrint('❌ IAP error ($productId): ${purchase.error}');
          completer?.complete(IapBuyResult.error);
          _pending.remove(productId);
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Validar recibo no backend ANTES de marcar como concluída.
          creditedSuccessfully = await _verifyAndCredit(purchase);
          completer?.complete(
            creditedSuccessfully
                ? IapBuyResult.success
                : IapBuyResult.error,
          );
          _pending.remove(productId);
          break;
      }

      // SÓ marca a compra como tratada na loja se:
      //  • status terminal (canceled/error) — não tem o que recuperar
      //  • OU foi creditada com sucesso no backend
      // Se o backend falhou em creditar (rede caiu, 500, etc), NÃO chamamos
      // completePurchase — assim a loja reentrega no próximo boot do app
      // via purchaseStream e o backend (idempotente por purchase_id)
      // tenta de novo até dar certo.
      final canFinalize =
          purchase.status == PurchaseStatus.canceled ||
              purchase.status == PurchaseStatus.error ||
              creditedSuccessfully;
      if (purchase.pendingCompletePurchase && canFinalize) {
        await _iap.completePurchase(purchase);
      } else if (purchase.pendingCompletePurchase) {
        debugPrint(
          '⏳ IAP $productId não finalizado — backend não creditou. '
          'Loja vai reentregar no próximo boot.',
        );
      }
    }
  }

  /// Envia o recibo ao backend para validação + crédito de coins.
  /// Retorna `true` se o backend validou com sucesso.
  Future<bool> _verifyAndCredit(PurchaseDetails purchase) async {
    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      await _creditsService.verifyIapPurchase(
        platform: platform,
        productId: purchase.productID,
        purchaseId: purchase.purchaseID ?? '',
        // Android: token; iOS: base64 receipt.
        verificationData:
            purchase.verificationData.serverVerificationData,
      );
      return true;
    } catch (e) {
      debugPrint('❌ IAP backend verify failed: $e');
      return false;
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
