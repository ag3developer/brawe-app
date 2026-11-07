// ============================================================================
// IAP SERVICE — Compra de Coins dentro do app (Google Play Billing / StoreKit 2)
// ============================================================================
// Coins compradas aqui servem só para gastar dentro da Brawe (presentes etc.).
//
// Fluxo:
//   1. `loadCatalog()` → o servidor diz se a venda está ligada e quais pacotes
//      oferecer (mesmos pacotes do admin; IDs por loja).
//   2. `loadProducts()` → preço/título localizados pela própria loja.
//   3. `buy(productId)` abre o sheet nativo. No Android a compra leva o
//      identificador da conta (obfuscatedAccountId) para o servidor conferir.
//   4. A loja confirma → o app manda ao servidor (`/credits/iap/verify`):
//      iOS a transação assinada (JWS do StoreKit 2), Android o purchase token.
//   5. Só depois de creditado chamamos `completePurchase()`; se falhar, a loja
//      reentrega a compra no próximo boot e o servidor (idempotente) credita.
// ============================================================================

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../config/feature_flags.dart';
import 'credits_service.dart';

part 'iap_service.g.dart';

/// Pacotes à venda na loja deste aparelho (vem do servidor).
class IapCatalog {
  const IapCatalog({required this.enabled, required this.coinsByProductId, required this.accountHash});

  static const empty = IapCatalog(enabled: false, coinsByProductId: {}, accountHash: '');

  /// Venda ligada no admin E há pacotes publicados nesta loja.
  final bool enabled;

  /// productId da loja → quantidade de Coins.
  final Map<String, int> coinsByProductId;

  /// Android: vai como obfuscatedAccountId (o servidor confere que a compra é desta conta).
  final String accountHash;

  factory IapCatalog.fromJson(Map<String, dynamic> j) {
    final map = <String, int>{};
    for (final p in (j['packages'] as List? ?? const [])) {
      if (p is Map && p['product_id'] is String && p['coins'] is num) {
        map[p['product_id'] as String] = (p['coins'] as num).toInt();
      }
    }
    return IapCatalog(
      enabled: j['enabled'] == true && map.isNotEmpty,
      coinsByProductId: map,
      accountHash: (j['account_hash'] ?? '').toString(),
    );
  }
}

/// Pacote pronto para a UI: Coins + produto da loja (com o preço da loja).
class IapOffer {
  const IapOffer({required this.coins, required this.product});
  final int coins;
  final ProductDetails product;
}

/// Resultado da operação `buy()`.
enum IapBuyResult {
  /// Compra finalizada e coins creditadas com sucesso.
  success,

  /// Usuário cancelou o sheet nativo de pagamento.
  cancelled,

  /// Compra pendente (ex.: pagamento ainda em processamento na loja).
  pending,

  /// Erro na loja (cartão recusado, sem conexão, produto inválido, etc).
  error,
}

@Riverpod(keepAlive: true)
IapService iapService(Ref ref) {
  return IapService(ref.watch(creditsServiceProvider));
}

/// A venda de Coins está aberta neste aparelho? (plataforma com loja + venda ligada no admin)
final iapCatalogProvider = FutureProvider.autoDispose<IapCatalog>((ref) async {
  final iap = ref.read(iapServiceProvider);
  if (!iap.supportsIap) return IapCatalog.empty;
  try {
    return await iap.loadCatalog();
  } catch (e) {
    debugPrint('⚠️  IAP catálogo indisponível: $e');
    return IapCatalog.empty;
  }
});

/// Mostrar pontos de compra (botão "Recarregar" etc.)? Flag do app + venda ligada no admin.
/// Observe com `ref.watch` no build para o catálogo carregar enquanto a tela está aberta.
final coinPurchaseOpenProvider = Provider.autoDispose<bool>(
  (ref) => kCoinPurchaseEnabled && (ref.watch(iapCatalogProvider).value?.enabled ?? false),
);

class IapService {
  final CreditsService _creditsService;
  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _sub;
  final Map<String, Completer<IapBuyResult>> _pending = {};
  List<ProductDetails> _products = const [];
  IapCatalog _catalog = IapCatalog.empty;
  bool _initialized = false;
  bool _available = false;

  IapService(this._creditsService);

  bool get isAvailable => _available;
  IapCatalog get catalog => _catalog;
  List<ProductDetails> get products => List.unmodifiable(_products);

  /// Plataforma suporta IAP?
  bool get supportsIap => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  String get _platform => Platform.isAndroid ? 'android' : 'ios';

  /// Inicializa o listener de compras (uma vez na vida do app). Também
  /// recebe compras que ficaram sem crédito em sessões anteriores.
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

  /// Pacotes do servidor para a loja deste aparelho.
  Future<IapCatalog> loadCatalog() async {
    _catalog = IapCatalog.fromJson(await _creditsService.getIapCatalog(platform: _platform));
    return _catalog;
  }

  /// Produtos da loja (preço localizado) para os pacotes do catálogo, do menor ao maior.
  Future<List<IapOffer>> loadOffers() async {
    if (!supportsIap || !_available) return const [];
    final catalog = await loadCatalog();
    if (!catalog.enabled) return const [];
    final response = await _iap.queryProductDetails(catalog.coinsByProductId.keys.toSet());
    if (response.error != null) {
      debugPrint('❌ IAP queryProductDetails: ${response.error}');
    }
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('⚠️  IAP productIds não encontrados na loja: ${response.notFoundIDs}');
    }
    _products = response.productDetails;
    final offers = [
      for (final p in _products)
        if (catalog.coinsByProductId[p.id] != null) IapOffer(coins: catalog.coinsByProductId[p.id]!, product: p),
    ]..sort((a, b) => a.coins.compareTo(b.coins));
    return offers;
  }

  /// Inicia o fluxo de compra. Resolve quando o servidor creditou (sucesso/erro/pendente)
  /// ou o usuário cancelou o sheet.
  Future<IapBuyResult> buy(String productId) async {
    if (!supportsIap || !_available) return IapBuyResult.error;

    final product = _products.where((p) => p.id == productId).firstOrNull;
    if (product == null) return IapBuyResult.error;

    // Já tem um Completer em andamento p/ esse produto? evita duplicação.
    _pending[productId]?.complete(IapBuyResult.cancelled);
    final completer = Completer<IapBuyResult>();
    _pending[productId] = completer;

    // Android: obfuscatedAccountId = hash da conta (o servidor confere).
    // iOS: o appAccountToken exige UUID — não enviamos (a transação é conferida pela assinatura da Apple).
    final purchaseParam = PurchaseParam(
      productDetails: product,
      applicationUserName: Platform.isAndroid && _catalog.accountHash.isNotEmpty ? _catalog.accountHash : null,
    );

    // Coins são CONSUMABLE (podem ser compradas várias vezes).
    final ok = await _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);

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
          debugPrint('💤 IAP pending: $productId');
          completer?.complete(IapBuyResult.pending);
          _pending.remove(productId);
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
          // Validar no servidor ANTES de marcar como concluída.
          creditedSuccessfully = await _verifyAndCredit(purchase);
          completer?.complete(creditedSuccessfully ? IapBuyResult.success : IapBuyResult.error);
          _pending.remove(productId);
          break;
      }

      // Só finaliza na loja se o status é terminal (cancelado/erro) ou se creditou.
      // Se o servidor falhou, a loja reentrega no próximo boot e o crédito é idempotente.
      final canFinalize = purchase.status == PurchaseStatus.canceled ||
          purchase.status == PurchaseStatus.error ||
          creditedSuccessfully;
      if (purchase.pendingCompletePurchase && canFinalize) {
        await _iap.completePurchase(purchase);
      } else if (purchase.pendingCompletePurchase) {
        debugPrint('⏳ IAP $productId não finalizado — servidor não creditou. A loja reentrega no próximo boot.');
      }
    }
  }

  /// Envia a compra ao servidor para conferir e creditar. `true` se creditou.
  Future<bool> _verifyAndCredit(PurchaseDetails purchase) async {
    try {
      await _creditsService.verifyIapPurchase(
        platform: _platform,
        productId: purchase.productID,
        purchaseId: purchase.purchaseID ?? '',
        // iOS: transação assinada (JWS, StoreKit 2); Android: purchase token.
        verificationData: purchase.verificationData.serverVerificationData,
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
