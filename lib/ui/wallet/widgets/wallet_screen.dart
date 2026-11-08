import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/feature_flags.dart';
import '../../../data/services/iap_service.dart';
import '../../../domain/models/wallet.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/ui/grouped_list.dart';
import '../../core/widgets/brawe_coin.dart';
import '../view_models/wallet_view_model.dart';
import 'earnings_screen.dart';
import 'gifters_section.dart';
import 'top_up_coins_sheet.dart';

/// Carteira no padrão de lista agrupada: saldo em destaque, ações em linhas,
/// histórico social e explicação curta em cartões.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final c = context.colors;
    final async = ref.watch(walletViewModelProvider);
    // Compra de moedas pela loja do aparelho (Apple/Google): só com a venda ligada no admin
    // (pacotes e preços vêm da loja, ver TopUpCoinsSheet).
    final canBuy =
        kCoinPurchaseEnabled &&
        (ref.watch(iapCatalogProvider).value?.enabled ?? false);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        title: Text(s.walletTitle),
        leading: const BackButton(),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          onRetry: () => ref.read(walletViewModelProvider.notifier).refresh(),
        ),
        data: (wallet) => RefreshIndicator(
          onRefresh: () => ref.read(walletViewModelProvider.notifier).refresh(),
          child: GroupedBody(
            children: [
              _BalanceCard(wallet: wallet),
              const SizedBox(height: 22),
              GroupedSection(
                children: [
                  if (canBuy)
                    GroupedRow(
                      icon: LucideIcons.coins,
                      title: s.walletSectionBuyTitle,
                      subtitle: s.walletSectionBuySubtitle,
                      onTap: () => TopUpCoinsSheet.show(context),
                    ),
                  // Nota: compra de coins é via IAP (Google Play / App Store),
                  // por isso não há atalho de "adicionar cartão".
                  GroupedRow(
                    icon: LucideIcons.history,
                    title: s.walletActionStatement,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EarningsScreen()),
                    ),
                  ),
                  GroupedRow(
                    icon: LucideIcons.send,
                    title: s.walletActionSend,
                    value: s.walletComingSoon,
                    onTap: () => ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(s.walletComingSoon))),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 7),
                child: Text(
                  s.walletSectionHistoryTitle.toUpperCase(),
                  style: TextStyle(
                    color: c.textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const GiftersSection(),
              const SizedBox(height: 22),
              GroupedSection(
                caption: s.walletInfoTitle,
                children: [
                  GroupedRow(
                    icon: LucideIcons.zap,
                    title: s.walletInfoQuestsTitle,
                    subtitle: s.walletInfoQuestsBody,
                  ),
                  GroupedRow(
                    icon: LucideIcons.gift,
                    title: s.walletInfoGiftsTitle,
                    subtitle: s.walletInfoGiftsBody,
                  ),
                  GroupedRow(
                    icon: LucideIcons.shoppingBag,
                    title: s.walletInfoUseTitle,
                    subtitle: s.walletInfoUseBody,
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

/// Saldo em destaque: cartão limpo, número grande, número da conta como legenda.
class _BalanceCard extends StatelessWidget {
  final Wallet wallet;
  const _BalanceCard({required this.wallet});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.wallet, color: c.textSecondary, size: 16),
              const SizedBox(width: 8),
              Text(
                S.of(context).walletAvailableBalance,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (wallet.accountNumber != null) ...[
                Icon(LucideIcons.hash, color: c.textTertiary, size: 12),
                const SizedBox(width: 2),
                Text(
                  wallet.accountNumber!,
                  style: TextStyle(color: c.textTertiary, fontSize: 12),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const BraweCoin(size: 34, glow: true),
              const SizedBox(width: 10),
              Text(
                _format(wallet.balance),
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  S.of(context).walletCoins,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _format(double n) {
    final i = n.truncate();
    final s = i.toString();
    final buf = StringBuffer();
    for (int j = 0; j < s.length; j++) {
      if (j > 0 && (s.length - j) % 3 == 0) buf.write('.');
      buf.write(s[j]);
    }
    return buf.toString();
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.circleAlert,
            size: 40,
            color: context.colors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(s.walletLoadError),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: Text(s.walletTryAgain)),
        ],
      ),
    );
  }
}
