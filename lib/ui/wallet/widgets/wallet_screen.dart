import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../data/services/iap_service.dart';
import '../../../domain/models/wallet.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/widgets/brawe_coin.dart';
import '../view_models/wallet_view_model.dart';
import 'earnings_screen.dart';
import 'gifters_section.dart';

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
              _SectionHeader(
                title: s.walletSectionBuyTitle,
                subtitle: s.walletSectionBuySubtitle,
              ),
              const SizedBox(height: 12),
              _PackagesGrid(
                packages: kCoinPackages,
                onSelect: (p) => _showPurchaseSheet(context, p),
              ),
              const SizedBox(height: 24),
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

  void _showPurchaseSheet(BuildContext context, CoinPackage pkg) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _PurchaseSheet(package: pkg),
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

class _PackagesGrid extends StatelessWidget {
  final List<CoinPackage> packages;
  final ValueChanged<CoinPackage> onSelect;
  const _PackagesGrid({required this.packages, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    // Responsivo: 3 colunas em telas normais, 4 em tablets/landscape
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 600 ? 4 : 3;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.78,
      ),
      itemCount: packages.length,
      itemBuilder: (_, i) => _PackageCard(
        package: packages[i],
        onTap: () => onSelect(packages[i]),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final CoinPackage package;
  final VoidCallback onTap;
  const _PackageCard({required this.package, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final highlight = package.popular || package.bestValue;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlight
                ? AppColors.braweBlue
                : Theme.of(context).dividerColor,
            width: highlight ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Label (popular / best value) ou espaço para alinhar
            SizedBox(
              height: 16,
              child: package.label.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.braweBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        package.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
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
                const SizedBox(height: 4),
                Text(
                  _formatInt(package.coins),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                Text(
                  S.of(context).walletCoins,
                  style: TextStyle(
                    fontSize: 9,
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
            // Preço
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.braweBlue.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                S
                    .of(context)
                    .walletPriceBRL(_formatInt(package.priceBRL.round())),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.braweBlue,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatInt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int j = 0; j < s.length; j++) {
      if (j > 0 && (s.length - j) % 3 == 0) buf.write('.');
      buf.write(s[j]);
    }
    return buf.toString();
  }
}

class _PurchaseSheet extends ConsumerStatefulWidget {
  final CoinPackage package;
  const _PurchaseSheet({required this.package});

  @override
  ConsumerState<_PurchaseSheet> createState() => _PurchaseSheetState();
}

class _PurchaseSheetState extends ConsumerState<_PurchaseSheet> {
  bool _loading = true;
  bool _purchasing = false;
  String? _error;
  ProductDetails? _product;

  /// Mapeia package_id interno → productId da loja (Play/App Store).
  String? get _iapProductId => kPackageIdToIapProductId[widget.package.id];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final iap = ref.read(iapServiceProvider);
    if (!iap.supportsIap) {
      setState(() {
        _loading = false;
        _error = S.of(context).walletIapNotSupported;
      });
      return;
    }
    await iap.init();
    if (!iap.isAvailable) {
      setState(() {
        _loading = false;
        _error = S.of(context).walletIapStoreUnavailable;
      });
      return;
    }
    final products = await iap.loadProducts();
    final productId = _iapProductId;
    final product = productId == null
        ? null
        : products.firstWhere(
            (p) => p.id == productId,
            orElse: () => products.isNotEmpty
                ? products.first
                : throw StateError('no product'),
          );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _product = (productId != null && products.any((p) => p.id == productId))
          ? product
          : null;
      if (_product == null) {
        _error = S.of(context).walletIapPackageUnavailable;
      }
    });
  }

  Future<void> _onBuy() async {
    final productId = _iapProductId;
    if (productId == null || _purchasing) return;
    setState(() {
      _purchasing = true;
      _error = null;
    });
    final iap = ref.read(iapServiceProvider);
    final result = await iap.buy(productId);
    if (!mounted) return;
    setState(() => _purchasing = false);

    switch (result) {
      case IapBuyResult.success:
        // Atualiza saldo e fecha o sheet.
        ref.read(walletViewModelProvider.notifier).refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S
                    .of(context)
                    .walletIapSuccess(
                      _PackageCard._formatInt(widget.package.coins),
                    ),
              ),
              backgroundColor: AppColors.braweBlue,
            ),
          );
          Navigator.of(context).pop();
        }
        break;
      case IapBuyResult.cancelled:
        setState(() => _error = null); // silencioso
        break;
      case IapBuyResult.pending:
        setState(() => _error = S.of(context).walletIapPaymentPending);
        break;
      case IapBuyResult.error:
        setState(() => _error = S.of(context).walletIapPaymentError);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pkg = widget.package;
    final priceLabel =
        _product?.price ??
        S
            .of(context)
            .walletPriceBRL(_PackageCard._formatInt(pkg.priceBRL.round()));

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: context.colors.textTertiary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              const BraweCoin(size: 44, glow: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S
                          .of(context)
                          .walletPackageCoins(
                            _PackageCard._formatInt(pkg.coins),
                          ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      priceLabel,
                      style: const TextStyle(
                        color: AppColors.braweBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.braweBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.braweBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.braweBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    S.of(context).walletIapInfo,
                    style: const TextStyle(height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (_loading || _purchasing || _product == null)
                  ? null
                  : _onBuy,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.braweBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                disabledBackgroundColor: AppColors.braweBlue.withValues(
                  alpha: 0.4,
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : _purchasing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          S.of(context).walletIapProcessing,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    )
                  : Text(
                      _product == null
                          ? S.of(context).walletIapUnavailable
                          : S.of(context).walletIapBuyFor(priceLabel),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
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
