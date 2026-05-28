// ============================================================================
// TOP-UP COINS SHEET — Recarga rápida de coins (estilo TikTok)
// ============================================================================
// Bottom sheet compacto que abre por cima de qualquer tela (gifts overlay,
// live, battle, etc.) para o usuário comprar mais coins SEM sair do contexto.
//
// Fluxo:
//   1. Mostra grid de packages
//   2. Tap → dispara IAP nativo (Play Store / App Store)
//   3. Compra confirmada → atualiza saldo + fecha sheet
//   4. Usuário volta exatamente onde estava (live, gifts, battle)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../data/services/iap_service.dart';
import '../../../domain/models/wallet.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/view_models/credits_view_model.dart';
import '../../core/widgets/brawe_coin.dart';

/// Bottom sheet de recarga rápida de coins.
///
/// Uso:
/// ```dart
/// await TopUpCoinsSheet.show(context, reason: 'gift'); // 'gift' | 'battle' | 'general'
/// ```
class TopUpCoinsSheet extends ConsumerStatefulWidget {
  /// Motivo opcional para mostrar mensagem contextual.
  /// - `gift`: "Saldo insuficiente para enviar este presente"
  /// - `battle`: "Continue na batalha! Recarregue para mandar mais gifts"
  /// - null/`general`: título padrão
  final String? reason;

  const TopUpCoinsSheet({super.key, this.reason});

  static Future<void> show(BuildContext context, {String? reason}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TopUpCoinsSheet(reason: reason),
    );
  }

  @override
  ConsumerState<TopUpCoinsSheet> createState() => _TopUpCoinsSheetState();
}

class _TopUpCoinsSheetState extends ConsumerState<TopUpCoinsSheet> {
  bool _loadingProducts = true;
  bool _purchasing = false;
  String? _purchasingPackageId;
  String? _error;
  Map<String, ProductDetails> _productsByPackageId = {};

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final iap = ref.read(iapServiceProvider);
    if (!iap.supportsIap) {
      if (!mounted) return;
      setState(() {
        _loadingProducts = false;
        _error = S.of(context).walletIapNotSupported;
      });
      return;
    }
    await iap.init();
    if (!iap.isAvailable) {
      if (!mounted) return;
      setState(() {
        _loadingProducts = false;
        _error = S.of(context).walletIapStoreUnavailable;
      });
      return;
    }
    final products = await iap.loadProducts();
    final byPackageId = <String, ProductDetails>{};
    for (final entry in kPackageIdToIapProductId.entries) {
      final found = products
          .where((p) => p.id == entry.value)
          .cast<ProductDetails?>()
          .firstWhere((_) => true, orElse: () => null);
      if (found != null) byPackageId[entry.key] = found;
    }
    if (!mounted) return;
    setState(() {
      _loadingProducts = false;
      _productsByPackageId = byPackageId;
    });
  }

  Future<void> _buy(CoinPackage pkg) async {
    if (_purchasing) return;
    final productId = kPackageIdToIapProductId[pkg.id];
    if (productId == null) {
      setState(() => _error = S.of(context).walletIapPackageUnavailable);
      return;
    }
    setState(() {
      _purchasing = true;
      _purchasingPackageId = pkg.id;
      _error = null;
    });
    final iap = ref.read(iapServiceProvider);
    final result = await iap.buy(productId);
    if (!mounted) return;
    setState(() {
      _purchasing = false;
      _purchasingPackageId = null;
    });

    switch (result) {
      case IapBuyResult.success:
        // Atualiza saldo no contexto (live, gifts, etc.)
        await ref.read(creditsViewModelProvider.notifier).refresh();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context).walletIapSuccess(_fmtInt(pkg.coins)),
            ),
            backgroundColor: AppColors.electricPurple,
          ),
        );
        Navigator.of(context).pop();
        break;
      case IapBuyResult.cancelled:
        break;
      case IapBuyResult.pending:
        setState(() => _error = S.of(context).walletIapPaymentPending);
        break;
      case IapBuyResult.error:
        setState(() => _error = S.of(context).walletIapPaymentError);
        break;
    }
  }

  String _titleForReason(BuildContext context) {
    final s = S.of(context);
    switch (widget.reason) {
      case 'gift':
        return s.topUpReasonGift;
      case 'battle':
        return s.topUpReasonBattle;
      default:
        return s.topUpTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final balance =
        ref.watch(creditsViewModelProvider).value?.toInt() ?? 0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2A1247),
            Color(0xFF160922),
            Color(0xFF0A0612),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Título + saldo atual
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _titleForReason(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.topUpSubtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const BraweCoin(size: 16, glow: true),
                        const SizedBox(width: 5),
                        Text(
                          _fmtInt(balance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Grid de packages (3 colunas, compacto)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.82,
                ),
                itemCount: kCoinPackages.length,
                itemBuilder: (_, i) {
                  final pkg = kCoinPackages[i];
                  final product = _productsByPackageId[pkg.id];
                  final isLoading = _purchasing &&
                      _purchasingPackageId == pkg.id;
                  return _TopUpPackageCard(
                    package: pkg,
                    priceLabel: product?.price ??
                        s.walletPriceBRL(_fmtInt(pkg.priceBRL.round())),
                    enabled: !_loadingProducts &&
                        !_purchasing &&
                        product != null,
                    loading: isLoading,
                    onTap: () => _buy(pkg),
                  );
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.red.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.redAccent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              // Disclaimer da loja
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    s.topUpStoreDisclaimer,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopUpPackageCard extends StatelessWidget {
  final CoinPackage package;
  final String priceLabel;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const _TopUpPackageCard({
    required this.package,
    required this.priceLabel,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = package.popular || package.bestValue;
    return Opacity(
      opacity: enabled || loading ? 1.0 : 0.5,
      child: Material(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: highlight
                    ? const Color(0xFFFF4F8B)
                    : Colors.white.withValues(alpha: 0.1),
                width: highlight ? 1.4 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Badge
                SizedBox(
                  height: 14,
                  child: package.label.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4F8B),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            package.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        )
                      : null,
                ),
                // Coin + valor
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BraweCoin(size: 22, glow: true),
                    const SizedBox(height: 3),
                    Text(
                      _fmtInt(package.coins),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                // Botão de preço
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4F8B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 12,
                          child: Center(
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.6,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          priceLabel,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 10.5,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _fmtInt(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (int j = 0; j < s.length; j++) {
    if (j > 0 && (s.length - j) % 3 == 0) buf.write('.');
    buf.write(s[j]);
  }
  return buf.toString();
}
