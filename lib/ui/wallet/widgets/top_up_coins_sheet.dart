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

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/feature_flags.dart';
import '../../../data/services/iap_service.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
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

  static Future<void> show(BuildContext context, {String? reason}) async {
    final messenger = ScaffoldMessenger.of(context);
    final disabledText = S.of(context).rewardsPurchaseDisabled;
    // Venda aberta? (flag do app + venda ligada no admin + pacotes publicados nesta loja)
    var open = false;
    if (kCoinPurchaseEnabled) {
      try {
        // sempre consulta de novo: o admin pode ter ligado/desligado a venda
        final catalog = await ProviderScope.containerOf(context, listen: false)
            .refresh(iapCatalogProvider.future)
            .timeout(const Duration(seconds: 6));
        open = catalog.enabled;
      } catch (_) {
        open = false;
      }
    }
    if (!open || !context.mounted) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(disabledText)));
      return;
    }
    return showModalBottomSheet<void>(
      useRootNavigator: true,
      useSafeArea: true,
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
  String? _purchasingProductId;
  String? _error;
  List<IapOffer> _offers = const [];

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
    List<IapOffer> offers = const [];
    try {
      offers = await iap.loadOffers();
    } catch (e) {
      debugPrint('❌ IAP loadOffers: $e');
    }
    if (!mounted) return;
    setState(() {
      _loadingProducts = false;
      _offers = offers;
      if (offers.isEmpty) _error = S.of(context).walletIapPackageUnavailable;
    });
  }

  Future<void> _buy(IapOffer offer) async {
    if (_purchasing) return;
    setState(() {
      _purchasing = true;
      _purchasingProductId = offer.product.id;
      _error = null;
    });
    final iap = ref.read(iapServiceProvider);
    final result = await iap.buy(offer.product.id);
    if (!mounted) return;
    setState(() {
      _purchasing = false;
      _purchasingProductId = null;
    });

    switch (result) {
      case IapBuyResult.success:
        // Atualiza saldo no contexto (live, gifts, etc.)
        await ref.read(creditsViewModelProvider.notifier).refresh();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).walletIapSuccess(_fmtInt(offer.coins))),
            backgroundColor: context.colors.accentPrimary,
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
    final balance = ref.watch(creditsViewModelProvider).value?.toInt() ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: context.colors.textTertiary.withValues(alpha: 0.4),
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
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.topUpSubtitle,
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const BraweCoin(size: 16, glow: true),
                        const SizedBox(width: 5),
                        Text(
                          _fmtInt(balance),
                          style: TextStyle(
                            color: context.colors.textPrimary,
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
              // Pacotes do admin, com o preço da própria loja (3 colunas, compacto)
              if (_loadingProducts)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: _offers.length,
                  itemBuilder: (_, i) {
                    final offer = _offers[i];
                    return _TopUpPackageCard(
                      coins: offer.coins,
                      // o pacote do meio ganha destaque
                      highlight:
                          _offers.length >= 3 && i == _offers.length ~/ 2,
                      priceLabel: offer.product.price,
                      enabled: !_purchasing,
                      loading:
                          _purchasing &&
                          _purchasingProductId == offer.product.id,
                      onTap: () => _buy(offer),
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
                      color: Colors.red.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.circleAlert,
                        color: context.colors.danger,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: context.colors.danger,
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
                    LucideIcons.lock,
                    size: 12,
                    color: context.colors.textTertiary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    // só a loja do aparelho (a Apple não aceita citar outra plataforma)
                    Platform.isIOS
                        ? s.topUpStoreDisclaimerApple
                        : s.topUpStoreDisclaimerGoogle,
                    style: TextStyle(
                      color: context.colors.textTertiary,
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
  final int coins;
  final bool highlight;
  final String priceLabel;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const _TopUpPackageCard({
    required this.coins,
    required this.highlight,
    required this.priceLabel,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled || loading ? 1.0 : 0.5,
      child: Material(
        color: context.colors.surfaceHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: highlight
                    ? context.colors.warning
                    : context.colors.border,
                width: highlight ? 1.4 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 14),
                // Coin + valor
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BraweCoin(size: 22, glow: true),
                    const SizedBox(height: 3),
                    Text(
                      _fmtInt(coins),
                      style: TextStyle(
                        color: context.colors.textPrimary,
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
                    color: context.colors.accentPrimary,
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
