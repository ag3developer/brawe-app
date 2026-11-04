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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final earnings = ref.watch(earningsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.earningsTitle),
        leading: const BackButton(),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _BalanceCard(data: data),
              const SizedBox(height: 24),
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
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//   Cartão único de saldo: chave Moedas | Diamantes, valor convertido,
//   seletor de moeda e totais da vida toda no rodapé.
// ───────────────────────────────────────────────────────────────────────────
class _BalanceCard extends ConsumerStatefulWidget {
  final Earnings data;
  const _BalanceCard({required this.data});

  @override
  ConsumerState<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends ConsumerState<_BalanceCard> {
  static const _currencies = ['USD', 'BRL', 'EUR'];
  bool _coins = true;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final data = widget.data;
    final currency = ref.watch(displayCurrencyProvider);

    final amount = _coins ? data.coinsBalance : data.diamondsBalance;
    final value = _coins ? data.coinsValueInCurrency : data.diamondsValueInCurrency;
    final label = _coins ? s.earningsCoinsBalance : s.rewardsDiamondsAvailable;
    final lifetimeLabel = _coins ? s.earningsTotalSpent : s.earningsTotalEarned;
    final lifetime = _coins ? data.coinsSpentLifetime : data.diamondsLifetime;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.braweBlue, AppColors.braweSky],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.braweBlue.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chave Moedas | Diamantes + moeda de exibição
          Row(
            children: [
              _CardToggle(
                coins: _coins,
                coinsLabel: s.rewardsToggleCoins,
                diamondsLabel: s.rewardsToggleDiamonds,
                onChanged: (v) => setState(() => _coins = v),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                initialValue: currency,
                tooltip: s.earningsCurrency,
                onSelected: (v) {
                  ref.read(displayCurrencyProvider.notifier).set(v);
                  ref.invalidate(earningsViewModelProvider);
                },
                itemBuilder: (_) => [
                  for (final c in _currencies)
                    CheckedPopupMenuItem(value: c, checked: c == currency, child: Text(c)),
                ],
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 5, 4, 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currency,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            child: Row(
              key: ValueKey(_coins),
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _coins
                    ? const BraweCoin(size: 34, glow: true)
                    : Image.asset(
                        'assets/images/illustrations/diamond_3d.png',
                        width: 36,
                        height: 36,
                        filterQuality: FilterQuality.medium,
                      ),
                const SizedBox(width: 10),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _formatInt(amount.round()),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '≈ ${_formatCurrency(value, data.currency)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.18)),
          const SizedBox(height: 10),
          // Rodapé: total da vida toda do tipo escolhido + Brawe ID
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '$lifetimeLabel  '),
                      TextSpan(
                        text: _formatInt(lifetime.round()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ),
              if (data.accountNumber != null) ...[
                const SizedBox(width: 8),
                Text(
                  'ID ${data.accountNumber!}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Chave Moedas | Diamantes dentro do cartão.
class _CardToggle extends StatelessWidget {
  final bool coins;
  final String coinsLabel;
  final String diamondsLabel;
  final ValueChanged<bool> onChanged;
  const _CardToggle({
    required this.coins,
    required this.coinsLabel,
    required this.diamondsLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget pill(String text, bool selected, bool value) => GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: selected ? AppColors.braweBlue : Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          pill(coinsLabel, coins, true),
          pill(diamondsLabel, !coins, false),
        ],
      ),
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
        // Título + seletor de período (um botão só, em vez de 4 chips)
        Row(
          children: [
            Expanded(
              child: Text(
                s.rewardsHistoryTitle,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            PopupMenuButton<_Period>(
              initialValue: _period,
              tooltip: s.rewardsPeriodLabel,
              onSelected: (p) => setState(() => _period = p),
              itemBuilder: (_) => [
                for (final p in _Period.values)
                  CheckedPopupMenuItem(
                    value: p,
                    checked: p == _period,
                    child: Text(periodLabels[p]!),
                  ),
              ],
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
                decoration: BoxDecoration(
                  color: colors.surfaceHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: colors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      periodLabels[_period]!,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, size: 20, color: colors.textSecondary),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Abas (segmentadas, compactas)
        Container(
          padding: const EdgeInsets.all(3),
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
            final groups = _GiftGroup.build(items);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PeriodSummary(
                  received: _received,
                  total: total,
                  count: groups.fold<int>(0, (n, g) => n + g.quantity),
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
                      for (int i = 0; i < groups.length; i++) ...[
                        _GiftTile(group: groups[i]),
                        if (i < groups.length - 1)
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
          padding: const EdgeInsets.symmetric(vertical: 8),
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

/// Mesmo presente + mesma pessoa + mesmo dia = uma linha só.
class _GiftGroup {
  _GiftGroup(this.tx) : quantity = tx.quantity < 1 ? 1 : tx.quantity, amount = tx.amountCredits.abs(), sends = 1;
  final WalletTransaction tx; // a mais recente do grupo
  int quantity;
  int amount;
  int sends;

  static String keyOf(WalletTransaction t) {
    final d = t.createdAt?.toLocal();
    final day = d == null ? '' : '${d.year}-${d.month}-${d.day}';
    final gift = t.giftSlug.isNotEmpty ? t.giftSlug : t.giftName;
    final who = t.counterpartyId.isNotEmpty ? t.counterpartyId : t.counterpartyName;
    return '${t.type}|$who|$gift|$day';
  }

  /// Agrupa mantendo a ordem (mais recente primeiro).
  static List<_GiftGroup> build(List<WalletTransaction> items) {
    final map = <String, _GiftGroup>{};
    final out = <_GiftGroup>[];
    for (final t in items) {
      final k = keyOf(t);
      final g = map[k];
      if (g == null) {
        final ng = _GiftGroup(t);
        map[k] = ng;
        out.add(ng);
      } else {
        g.quantity += t.quantity < 1 ? 1 : t.quantity;
        g.amount += t.amountCredits.abs();
        g.sends += 1;
      }
    }
    return out;
  }
}

class _GiftTile extends StatelessWidget {
  final _GiftGroup group;
  const _GiftTile({required this.group});

  WalletTransaction get tx => group.tx;

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
                  group.quantity > 1 ? '$name  ×${group.quantity}' : name,
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
            amount: group.amount,
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
