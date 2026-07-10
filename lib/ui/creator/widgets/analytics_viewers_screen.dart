import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../view_models/creator_analytics_view_model.dart';
import 'analytics_chart_painter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ANALYTICS — VIEWERS / AUDIÊNCIA
// GET /analytics/viewers?period=30d
// ─────────────────────────────────────────────────────────────────────────────

class AnalyticsViewersScreen extends ConsumerWidget {
  const AnalyticsViewersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final period = ref.watch(analyticsPeriodProvider);
    final pointsAsync = ref.watch(viewersHistoryProvider(period));
    final kpisAsync = ref.watch(creatorDashboardKpisProvider);

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
          s.analyticsViewersTitle,
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
                kpisAsync.when(
                  loading: () => const AnalyticsKpiRow(items: null),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (k) => AnalyticsKpiRow(
                    items: [
                      AnalyticsKpiItem(
                        icon: LucideIcons.eye,
                        color: const Color(0xFF3B82F6),
                        label: s.analyticsViewersTotalViewers,
                        value: analyticsFormatCount(k.totalViewers),
                      ),
                      AnalyticsKpiItem(
                        icon: LucideIcons.trendingUp,
                        color: const Color(0xFF10B981),
                        label: s.analyticsViewersAvgPerLive,
                        value: k.avgViewersPerLive.toStringAsFixed(0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  s.analyticsViewersChartTitle,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    AnalyticsLegendDot(
                      color: const Color(0xFF3B82F6),
                      label: s.analyticsViewersLegendViewers,
                    ),
                    const SizedBox(width: 12),
                    AnalyticsLegendDot(
                      color: const Color(0xFFEC4899),
                      label: s.analyticsViewersLegendPeak,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                pointsAsync.when(
                  loading: () => const AnalyticsChartSkeleton(),
                  error: (e, _) => AnalyticsChartError(message: '$e'),
                  data: (points) => AnalyticsChartCard(
                    child: AnalyticsLineChart(
                      points: points,
                      color: const Color(0xFF3B82F6),
                      showSecondary: true,
                      secondaryColor: const Color(0xFFEC4899),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  s.analyticsViewersBestDays,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                pointsAsync.when(
                  loading: () => const AnalyticsListSkeleton(count: 5),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (points) {
                    final sorted = [...points]
                      ..sort((a, b) => b.value.compareTo(a.value));
                    final top = sorted.take(5).toList();
                    if (top.isEmpty) {
                      return Center(child: Text(s.analyticsViewersNoData));
                    }
                    return Column(
                      children: top.asMap().entries.map((e) {
                        final rank = e.key + 1;
                        final pt = e.value;
                        final pct = sorted.first.value > 0
                            ? pt.value / sorted.first.value
                            : 0.0;
                        return _DayRankTile(
                          rank: rank,
                          date: pt.date,
                          value: pt.value.toInt(),
                          pct: pct,
                          color: const Color(0xFF3B82F6),
                        );
                      }).toList(),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayRankTile extends StatelessWidget {
  final int rank;
  final DateTime date;
  final int value;
  final double pct;
  final Color color;

  const _DayRankTile({
    required this.rank,
    required this.date,
    required this.value,
    required this.pct,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final months = s.analyticsLivesMonthsShort.split(',');
    final dateStr = '${date.day} ${months[date.month - 1]}';
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
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
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            analyticsFormatCount(value),
            style: TextStyle(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          Text(
            s.analyticsViewersUnit,
            style: TextStyle(color: context.colors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
