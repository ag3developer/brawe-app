import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../view_models/creator_analytics_view_model.dart';
import 'analytics_chart_painter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ANALYTICS — ALCANCE / REACH
// GET /analytics/top-gifts     → gifts mais recebidos
// GET /analytics/earnings      → ganhos com fator de alcance
// GET /analytics/dashboard     → KPIs gerais (gifts, products)
// ─────────────────────────────────────────────────────────────────────────────

class AnalyticsReachScreen extends ConsumerWidget {
  const AnalyticsReachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final period = ref.watch(analyticsPeriodProvider);
    final kpisAsync = ref.watch(creatorDashboardKpisProvider);
    final topGiftsAsync = ref.watch(topGiftsProvider());
    final earningsAsync = ref.watch(earningsHistoryProvider(period));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.colors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: context.colors.background.withValues(alpha: 0.88),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: const SizedBox.expand(),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            size: 20,
            color: context.colors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          s.analyticsReachTitle,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        actions: [
          AnalyticsPeriodPicker(
            selected: period,
            onChanged: (p) => ref.read(analyticsPeriodProvider.notifier).set(p),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
              left: 16,
              right: 16,
              bottom: 32,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // KPI banners
                kpisAsync.when(
                  loading: () => const AnalyticsKpiRow(items: null),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (k) => AnalyticsKpiRow(
                    items: [
                      AnalyticsKpiItem(
                        icon: LucideIcons.gift,
                        color: const Color(0xFFF59E0B),
                        label: s.analyticsReachKpiGifts,
                        value: analyticsFormatCount(k.totalGiftsReceived),
                      ),
                      AnalyticsKpiItem(
                        icon: LucideIcons.dollarSign,
                        color: const Color(0xFF10B981),
                        label: s.analyticsReachKpiEarnings,
                        value: k.totalEarnings.toStringAsFixed(2),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Gráfico de ganhos
                Text(
                  s.analyticsReachEarningsChartTitle,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(children: [_EarningsLegend(s: s)]),
                const SizedBox(height: 8),

                earningsAsync.when(
                  loading: () => AnalyticsChartSkeleton(),
                  error: (e, _) => AnalyticsChartError(message: '$e'),
                  data: (points) => AnalyticsChartCard(
                    child: AnalyticsLineChart(
                      points: points,
                      color: const Color(0xFF10B981),
                      showSecondary: true,
                      secondaryColor: const Color(0xFFF59E0B),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Top Gifts
                Text(
                  s.analyticsReachTopGiftsTitle,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),

                topGiftsAsync.when(
                  loading: () => const AnalyticsListSkeleton(count: 5),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (gifts) {
                    if (gifts.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            s.analyticsReachNoGifts,
                            style: TextStyle(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }
                    final maxCount =
                        (gifts.first['count'] as num?)?.toDouble() ?? 1;
                    return Column(
                      children: gifts.asMap().entries.map((e) {
                        final rank = e.key + 1;
                        final g = e.value;
                        final count = (g['count'] as num?)?.toInt() ?? 0;
                        final totalUsdt =
                            (g['total_usdt'] as num?)?.toDouble() ?? 0;
                        final giftName = g['gift_name']?.toString() ?? 'Gift';
                        final pct = maxCount > 0 ? count / maxCount : 0.0;

                        return _GiftRankTile(
                          rank: rank,
                          name: giftName,
                          count: count,
                          totalUsdt: totalUsdt,
                          pct: pct,
                          isDark: isDark,
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Resumo de monetização
                kpisAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (k) => _MonetizationSummary(kpis: k, isDark: isDark),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _EarningsLegend extends StatelessWidget {
  final S s;
  const _EarningsLegend({required this.s});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Dot(
          color: const Color(0xFF10B981),
          label: s.analyticsReachLegendEarnings,
        ),
        const SizedBox(width: 12),
        _Dot(color: const Color(0xFFF59E0B), label: s.analyticsReachLegendFee),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: context.colors.textSecondary),
        ),
      ],
    );
  }
}

class _GiftRankTile extends StatelessWidget {
  final int rank;
  final String name;
  final int count;
  final double totalUsdt;
  final double pct;
  final bool isDark;

  const _GiftRankTile({
    required this.rank,
    required this.name,
    required this.count,
    required this.totalUsdt,
    required this.pct,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const giftColor = Color(0xFFF59E0B);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: rank == 1
                    ? const Color(0xFFF59E0B)
                    : context.colors.textTertiary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: giftColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.gift, size: 15, color: giftColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 3,
                    backgroundColor: giftColor.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation(giftColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$count×',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              Text(
                '${totalUsdt.toStringAsFixed(1)} USDT',
                style: TextStyle(
                  color: const Color(0xFF10B981),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonetizationSummary extends StatelessWidget {
  final CreatorDashboardKpis kpis;
  final bool isDark;

  const _MonetizationSummary({required this.kpis, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withValues(alpha: isDark ? 0.12 : 0.08),
            const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.08 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.barChart2,
                color: Color(0xFF10B981),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                S.of(context).analyticsReachMonetizationTitle,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MoneyItem(
                label: S.of(context).analyticsReachTotalEarned,
                value: '${kpis.totalEarnings.toStringAsFixed(2)} USDT',
                color: const Color(0xFF10B981),
              ),
              _MoneyItem(
                label: S.of(context).analyticsReachTotalGifts,
                value: '${kpis.totalGiftsReceived}',
                color: const Color(0xFFF59E0B),
              ),
              _MoneyItem(
                label: S.of(context).analyticsReachEarningsPerLive,
                value: kpis.totalLives > 0
                    ? '${(kpis.totalEarnings / kpis.totalLives).toStringAsFixed(2)} U'
                    : '—',
                color: AppColors.electricPurple,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoneyItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MoneyItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: context.colors.textSecondary, fontSize: 10),
        ),
      ],
    );
  }
}
