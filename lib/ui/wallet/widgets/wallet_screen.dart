import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/feature_flags.dart';
import '../../../data/services/iap_service.dart';
import '../../../domain/models/wallet.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/widgets/brawe_coin.dart';
import '../view_models/wallet_view_model.dart';
import 'earnings_screen.dart';
import 'gifters_section.dart';
import 'top_up_coins_sheet.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final async = ref.watch(walletViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.walletTitle), leading: const BackButton()),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          onRetry: () => ref.read(walletViewModelProvider.notifier).refresh(),
        ),
        data: (wallet) => RefreshIndicator(
          onRefresh: () => ref.read(walletViewModelProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _BalanceCard(wallet: wallet),
              const SizedBox(height: 16),
              const _QuickActionsRow(),
              const SizedBox(height: 24),
              // Compra de moedas pela loja do aparelho: só com a venda ligada no admin
              // (os pacotes e preços vêm da loja, ver TopUpCoinsSheet).
              if (kCoinPurchaseEnabled && (ref.watch(iapCatalogProvider).value?.enabled ?? false)) ...[
                _SectionHeader(
                  title: s.walletSectionBuyTitle,
                  subtitle: s.walletSectionBuySubtitle,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () => TopUpCoinsSheet.show(context),
                    icon: const BraweCoin(size: 18),
                    label: Text(s.walletSectionBuyTitle),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              _SectionHeader(
                title: s.walletSectionHistoryTitle,
                subtitle: s.walletSectionHistorySubtitle,
              ),
              const SizedBox(height: 12),
              const GiftersSection(),
              const SizedBox(height: 20),
              const _InfoCard(),
            ],
          ),
        ),
      ),
    );
  }

}

class _BalanceCard extends StatelessWidget {
  final Wallet wallet;
  const _BalanceCard({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.braweBlue, AppColors.braweSky],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                S.of(context).walletAvailableBalance,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const BraweCoin(size: 40, glow: true),
              const SizedBox(width: 10),
              Text(
                _format(wallet.balance),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  S.of(context).walletCoins,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (wallet.accountNumber != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tag, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    wallet.accountNumber!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: scheme.onSurface.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    final items = <(IconData, String, String)>[
      (Icons.bolt_outlined, s.walletInfoQuestsTitle, s.walletInfoQuestsBody),
      (
        Icons.card_giftcard_outlined,
        s.walletInfoGiftsTitle,
        s.walletInfoGiftsBody,
      ),
      (Icons.shopping_bag_outlined, s.walletInfoUseTitle, s.walletInfoUseBody),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.walletInfoTitle,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (it) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(it.$1, color: AppColors.braweBlue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          it.$2,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          it.$3,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
          const Icon(Icons.error_outline, size: 40),
          const SizedBox(height: 12),
          Text(s.walletLoadError),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: Text(s.walletTryAgain)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick actions row
// ---------------------------------------------------------------------------
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    // Nota: compra de coins é via IAP (Google Play / App Store), por isso
    // não há atalho de "adicionar cartão" — o método de pagamento é
    // gerenciado pela loja do dispositivo.
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.send,
            label: s.walletActionSend,
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(s.walletComingSoon)));
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.history,
            label: s.walletActionStatement,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const EarningsScreen()));
            },
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.braweBlue, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// NOTE: legacy `_TransactionsList` / `_TransactionTile` removidos — substituídos
// pelo `GiftersSection` (lista social agrupada por pessoa).
