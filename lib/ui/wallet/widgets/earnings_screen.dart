// ============================================================================
// EARNINGS SCREEN — Saldo Consolidado & Histórico
// ============================================================================
// Tela "Meu Saldo" focada em VISUALIZAR ganhos:
//   • Cards com coins e diamonds + valor convertido em USD/BRL/EUR
//   • Seletor de moeda no AppBar
//   • Histórico de pedidos de compra de coins (Wolknow / IAP)
//   • Histórico de gifts recebidos (origem dos diamantes)
//
// Para COMPRAR moedas o usuário continua indo na Wallet (botão dedicado).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/feature_flags.dart';
import '../../../core/utils/gift_names.dart';
import '../../../domain/models/wallet.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/widgets/brawe_coin.dart';
import '../../core/widgets/gift_icon.dart';
import '../view_models/earnings_view_model.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  static const _currencies = ['USD', 'BRL', 'EUR'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final earnings = ref.watch(earningsViewModelProvider);
    final currency = ref.watch(displayCurrencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.earningsTitle),
        leading: const BackButton(),
        actions: [
          PopupMenuButton<String>(
            initialValue: currency,
            tooltip: s.earningsCurrency,
            onSelected: (v) {
              ref.read(displayCurrencyProvider.notifier).set(v);
              ref.invalidate(earningsViewModelProvider);
            },
            itemBuilder: (_) => [
              for (final c in _currencies)
                PopupMenuItem(
                  value: c,
                  child: Row(
                    children: [
                      if (c == currency)
                        const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.braweBlue,
                        )
                      else
                        const SizedBox(width: 16),
                      const SizedBox(width: 8),
                      Text(c),
                    ],
                  ),
                ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  Text(
                    currency,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: earnings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _ErrorView(
          onRetry: () => ref.read(earningsViewModelProvider.notifier).refresh(),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            await ref.read(earningsViewModelProvider.notifier).refresh();
            ref.invalidate(purchaseOrdersProvider);
            ref.invalidate(rewardsTransactionsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _BalanceCards(data: data),
              const SizedBox(height: 16),
              _LifetimeStats(data: data),
              const SizedBox(height: 28),
              _SectionHeader(
                title: s.rewardsHistoryTitle,
                subtitle: s.rewardsHistorySubtitle,
              ),
              const SizedBox(height: 12),
              const _GiftHistory(),
              // Histórico de compras só existe com a compra de moedas ativa.
              if (kCoinPurchaseEnabled) ...[
                const SizedBox(height: 28),
                _SectionHeader(
                  title: s.earningsPurchaseHistoryTitle,
                  subtitle: s.earningsPurchaseHistorySubtitle,
                ),
                const SizedBox(height: 12),
                const _PurchaseOrdersList(),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//   Cards de saldo (Coins + Diamonds) lado a lado
// ───────────────────────────────────────────────────────────────────────────
class _BalanceCards extends StatelessWidget {
  final Earnings data;
  const _BalanceCards({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BalanceTile(
            label: S.of(context).earningsCoinsBalance,
            amount: _formatInt(data.coinsBalance.round()),
            valueInCurrency: _formatCurrency(
              data.coinsValueInCurrency,
              data.currency,
            ),
            gradient: const [AppColors.braweBlue, AppColors.braweSky],
            icon: const BraweCoin(size: 28, glow: true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BalanceTile(
            label: S.of(context).earningsDiamondsBalance,
            amount: _formatInt(data.diamondsBalance.round()),
            valueInCurrency: _formatCurrency(
              data.diamondsValueInCurrency,
              data.currency,
            ),
            gradient: const [AppColors.braweSky, AppColors.braweDeep],
            icon: Image.asset(
              'assets/images/illustrations/diamond_3d.png',
              width: 32,
              height: 32,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ],
    );
  }
}

class _BalanceTile extends StatelessWidget {
  final String label;
  final String amount;
  final String valueInCurrency;
  final List<Color> gradient;
  final Widget icon;

  const _BalanceTile({
    required this.label,
    required this.amount,
    required this.valueInCurrency,
    required this.gradient,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '≈ $valueInCurrency',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//   Estatísticas (lifetime) — coins gastas, diamantes ganhos no total
// ───────────────────────────────────────────────────────────────────────────
class _LifetimeStats extends StatelessWidget {
  final Earnings data;
  const _LifetimeStats({required this.data});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          _StatRow(
            icon: Icons.savings_outlined,
            label: s.earningsTotalSpent,
            value: _formatInt(data.coinsSpentLifetime.round()),
            unit: s.walletCoins,
          ),
          const Divider(height: 20),
          _StatRow(
            icon: Icons.workspace_premium_outlined,
            label: s.earningsTotalEarned,
            value: _formatInt(data.diamondsLifetime.round()),
            unit: s.earningsDiamonds,
          ),
          if (data.accountNumber != null) ...[
            const Divider(height: 20),
            _StatRow(
              icon: Icons.tag,
              label: s.earningsAccountNumber,
              value: data.accountNumber!,
              unit: '',
              monospace: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final bool monospace;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.braweBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            fontFamily: monospace ? 'monospace' : null,
          ),
        ),
        if (unit.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            unit,
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//   Cabeçalho de seção
// ───────────────────────────────────────────────────────────────────────────
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
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: scheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//   Lista de pedidos de compra
// ───────────────────────────────────────────────────────────────────────────
class _PurchaseOrdersList extends ConsumerWidget {
  const _PurchaseOrdersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(purchaseOrdersProvider);
    final scheme = Theme.of(context).colorScheme;
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => _EmptyTile(text: S.of(context).earningsLoadError),
      data: (items) {
        if (items.isEmpty) {
          return _EmptyTile(
            text: S.of(context).earningsNoPurchases,
            hint: S.of(context).earningsNoPurchasesHint,
            illustrationAsset: 'assets/images/illustrations/package_3d.png',
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _PurchaseOrderTile(order: items[i]),
                if (i < items.length - 1)
                  Divider(height: 1, color: Theme.of(context).dividerColor),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PurchaseOrderTile extends StatelessWidget {
  final PurchaseOrder order;
  const _PurchaseOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;

    final (statusColor, statusLabel) = switch (order.status) {
      'completed' => (Colors.green, s.earningsStatusCompleted),
      'pending' => (Colors.orange, s.earningsStatusPending),
      'failed' => (Colors.redAccent, s.earningsStatusFailed),
      'refunded' => (Colors.blueGrey, s.earningsStatusRefunded),
      _ => (scheme.onSurface, order.status),
    };

    final methodLabel = switch (order.method) {
      'iap_android' => 'Google Play',
      'iap_ios' => 'App Store',
      'wolknow' => 'Wolknow',
      'pix' => 'PIX',
      '' => '—',
      _ => order.method,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.braweBlue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(child: BraweCoin(size: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '+${_formatInt(order.coins)} ${s.walletCoins}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$methodLabel · ${_formatDate(order.createdAt)}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (order.amount > 0)
                Text(
                  _formatCurrency(order.amount, order.currency),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//   Histórico de presentes: abas Recebidos/Enviados + filtro de período
// ───────────────────────────────────────────────────────────────────────────
enum _Period { today, week, month, all }

class _GiftHistory extends ConsumerStatefulWidget {
  const _GiftHistory();

  @override
  ConsumerState<_GiftHistory> createState() => _GiftHistoryState();
}

class _GiftHistoryState extends ConsumerState<_GiftHistory> {
  bool _received = true;
  _Period _period = _Period.all;

  DateTime? get _since {
    final now = DateTime.now();
    return switch (_period) {
      _Period.today => DateTime(now.year, now.month, now.day),
      _Period.week => now.subtract(const Duration(days: 7)),
      _Period.month => now.subtract(const Duration(days: 30)),
      _Period.all => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final async = ref.watch(rewardsTransactionsProvider);

    final periodLabels = {
      _Period.today: s.rewardsPeriodToday,
      _Period.week: s.rewardsPeriod7d,
      _Period.month: s.rewardsPeriod30d,
      _Period.all: s.rewardsPeriodAll,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Abas (segmentadas)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              _TabPill(
                label: s.rewardsTabReceived,
                selected: _received,
                onTap: () => setState(() => _received = true),
              ),
              _TabPill(
                label: s.rewardsTabSent,
                selected: !_received,
                onTap: () => setState(() => _received = false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Filtro de período
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final p in _Period.values) ...[
                ChoiceChip(
                  label: Text(periodLabels[p]!),
                  selected: _period == p,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _period = p),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, _) => _EmptyTile(text: s.earningsLoadError),
          data: (all) {
            final type = _received ? 'received' : 'sent';
            final ofType = all.where((t) => t.type == type).toList();
            final since = _since;
            final items = since == null
                ? ofType
                : ofType
                      .where(
                        (t) => t.createdAt != null &&
                            t.createdAt!.toLocal().isAfter(since),
                      )
                      .toList();
            if (ofType.isEmpty) {
              return _received
                  ? _EmptyTile(
                      text: s.earningsNoGifts,
                      hint: s.earningsNoGiftsHint,
                      illustrationAsset:
                          'assets/images/illustrations/gift_3d.png',
                    )
                  : _EmptyTile(
                      text: s.rewardsNoSent,
                      hint: s.rewardsNoSentHint,
                      illustrationAsset:
                          'assets/images/illustrations/gift_3d.png',
                    );
            }
            if (items.isEmpty) {
              return _EmptyTile(
                text: s.rewardsNoPeriod,
                hint: s.rewardsNoPeriodHint,
              );
            }
            final total = items.fold<int>(
              0,
              (sum, t) => sum + t.amountCredits.abs(),
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PeriodSummary(
                  received: _received,
                  total: total,
                  count: items.length,
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < items.length; i++) ...[
                        _GiftTile(tx: items[i]),
                        if (i < items.length - 1)
                          Divider(
                            height: 1,
                            indent: 72,
                            color: Theme.of(context).dividerColor,
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.braweBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              color: selected ? Colors.white : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PeriodSummary extends StatelessWidget {
  final bool received;
  final int total;
  final int count;
  const _PeriodSummary({
    required this.received,
    required this.total,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            received ? s.rewardsPeriodTotalReceived : s.rewardsPeriodTotalSent,
            style: TextStyle(color: colors.textSecondary, fontSize: 12.5),
          ),
        ),
        _AmountBadge(received: received, amount: total, signed: false),
        const SizedBox(width: 8),
        Text(
          s.rewardsGiftsCount(count),
          style: TextStyle(color: colors.textTertiary, fontSize: 12),
        ),
      ],
    );
  }
}

/// Valor com ícone: diamante para recebidos, moeda para enviados.
class _AmountBadge extends StatelessWidget {
  final bool received;
  final int amount;
  final bool signed;
  const _AmountBadge({
    required this.received,
    required this.amount,
    required this.signed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final prefix = !signed ? '' : (received ? '+' : '-');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        received
            ? Image.asset(
                'assets/images/illustrations/diamond_3d.png',
                width: 16,
                height: 16,
              )
            : const BraweCoin(size: 16),
        const SizedBox(width: 4),
        Text(
          '$prefix${_formatInt(amount)}',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: signed && received ? Colors.green : colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _GiftTile extends StatelessWidget {
  final WalletTransaction tx;
  const _GiftTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final received = tx.type == 'received';
    final name = tx.giftSlug.isEmpty
        ? tx.giftName
        : GiftNames.of(context, tx.giftSlug, fallback: tx.giftName);
    final who = s.rewardsFromTo(
      received ? s.walletTxFrom : s.walletTxTo,
      tx.counterpartyName,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.braweBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: GiftIcon(
              slug: tx.giftSlug,
              tier: tx.giftTier,
              iconUrl: tx.giftIconUrl,
              size: 34,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.quantity > 1 ? '$name  x${tx.quantity}' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$who · ${_formatDate(tx.createdAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _AmountBadge(
            received: received,
            amount: tx.amountCredits.abs(),
            signed: true,
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//   Empty / Error tile compartilhado
//   Layout: imagem pequena à esquerda + texto + hint contextual à direita
// ───────────────────────────────────────────────────────────────────────────
class _EmptyTile extends StatelessWidget {
  final String text;
  final String? illustrationAsset;
  final String? hint;
  const _EmptyTile({required this.text, this.illustrationAsset, this.hint});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (illustrationAsset != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Image.asset(
                illustrationAsset!,
                width: 48,
                height: 48,
                filterQuality: FilterQuality.medium,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (hint != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    hint!,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.55),
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
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
          Text(s.earningsLoadError),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: Text(s.walletTryAgain)),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//   Helpers
// ───────────────────────────────────────────────────────────────────────────
String _formatInt(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (int j = 0; j < s.length; j++) {
    if (j > 0 && (s.length - j) % 3 == 0) buf.write('.');
    buf.write(s[j]);
  }
  return buf.toString();
}

String _formatCurrency(double value, String currency) {
  final symbol = switch (currency) {
    'USD' => '\$',
    'BRL' => 'R\$',
    'EUR' => '€',
    _ => '$currency ',
  };
  // formato: SYMBOL 1.234,56
  final intPart = value.truncate();
  final decPart = ((value - intPart) * 100).round().abs().toString().padLeft(
    2,
    '0',
  );
  return '$symbol ${_formatInt(intPart)},$decPart';
}

String _formatDate(DateTime? d) {
  if (d == null) return '';
  String two(int x) => x.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}
