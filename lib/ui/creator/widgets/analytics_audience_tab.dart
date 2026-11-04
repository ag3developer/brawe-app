import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../view_models/creator_analytics_view_model.dart';
import 'analytics/analytics_async_chart.dart';
import 'analytics/analytics_charts.dart';
import 'analytics/analytics_data.dart';
import 'analytics/analytics_format.dart';
import 'analytics/analytics_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ANALYTICS — AUDIÊNCIA
// GET /analytics/viewers → espectadores/pico por dia + período anterior
// ─────────────────────────────────────────────────────────────────────────────

class AnalyticsAudienceBody extends ConsumerWidget {
  const AnalyticsAudienceBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final fmt = AnalyticsFmt.of(context);
    final period = ref.watch(analyticsPeriodProvider);
    final async = ref.watch(viewersSeriesProvider(period));
    const viewColor = AppColors.braweBlue;
    const peakColor = AppColors.hotPink;

    List<AnalyticsKpi>? kpis;
    final data = async.value;
    if (data != null) {
      kpis = [
        AnalyticsKpi(
          icon: LucideIcons.eye,
          color: viewColor,
          label: s.analyticsViewersTotalViewers,
          value: data.val('viewers'),
          format: fmt.compact,
          deltaPct: data.pct('viewers_change_pct'),
        ),
        AnalyticsKpi(
          icon: LucideIcons.trendingUp,
          color: AppColors.success,
          label: s.analyticsViewersAvgPerLive,
          value: data.val('avg_per_live'),
          format: fmt.compact,
          deltaPct: data.pct('avg_change_pct'),
        ),
        AnalyticsKpi(
          icon: LucideIcons.flame,
          color: peakColor,
          label: s.analyticsViewersKpiPeak,
          value: data.val('peak_viewers'),
          format: fmt.compact,
          deltaPct: data.pct('peak_change_pct'),
        ),
        AnalyticsKpi(
          icon: LucideIcons.radio,
          color: AppColors.braweOrange,
          label: s.analyticsLivesKpiTotal,
          value: data.val('lives'),
          format: fmt.integer,
          hasDelta: false,
        ),
      ];
    }

    return AnalyticsTabScroll(
      onRefresh: () async {
        ref.invalidate(viewersSeriesProvider(period));
        await ref
            .read(viewersSeriesProvider(period).future)
            .then((_) {}, onError: (_) {});
      },
      children: [
        AnalyticsKpiGrid(kpis: kpis, skeletonCount: 4),
        const SizedBox(height: 16),
        AnalyticsChartPanel(
          title: s.analyticsViewersChartTitle,
          builder: (compare) => AnalyticsAsyncChart(
            async: async,
            onRetry: () => ref.invalidate(viewersSeriesProvider(period)),
            isEmpty: (d) => d.emptyFor() && d.emptyFor(second: true),
            emptyMessage: s.analyticsEmptyViewers(
              analyticsRangeLabel(s, period),
            ),
            builder: (d) => seriesLineChart(
              context,
              d,
              label: s.analyticsViewersLegendViewers,
              color: viewColor,
              compare: compare,
              integer: true,
              format: fmt.integer,
              extra: [
                ChartLine(
                  label: s.analyticsViewersLegendPeak,
                  color: peakColor,
                  values: [for (final p in d.current) p.second ?? 0],
                ),
              ],
            ),
          ),
          legendBuilder: (compare) => seriesLegend(context, [
            (color: viewColor, label: s.analyticsViewersLegendViewers),
            (color: peakColor, label: s.analyticsViewersLegendPeak),
          ], compare),
        ),
        AnalyticsSectionTitle(title: s.analyticsViewersBestDays),
        async.when(
          loading: () => const Column(
            children: [
              AnalyticsSkeleton(height: 56, radius: 16),
              SizedBox(height: 8),
              AnalyticsSkeleton(height: 56, radius: 16),
              SizedBox(height: 8),
              AnalyticsSkeleton(height: 56, radius: 16),
            ],
          ),
          error: (_, _) => AnalyticsErrorView(
            height: 150,
            onRetry: () => ref.invalidate(viewersSeriesProvider(period)),
          ),
          data: (d) {
            final top = d.current.where((p) => p.value > 0).toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            if (top.isEmpty) {
              return AnalyticsCard(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    s.analyticsNoDataTitle,
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                ),
              );
            }
            final best = top.take(5).toList();
            return AnalyticsCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < best.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        indent: 40,
                        color: context.colors.border,
                      ),
                    _DayTile(
                      rank: i + 1,
                      point: best[i],
                      pct: best[i].value / best.first.value,
                      weekly: period == '365d',
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DayTile extends StatelessWidget {
  final int rank;
  final SeriesPoint point;
  final double pct;
  final bool weekly;
  const _DayTile({
    required this.rank,
    required this.point,
    required this.pct,
    required this.weekly,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fmt = AnalyticsFmt.of(context);
    final s = S.of(context);
    final first = rank == 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: first ? AppColors.amber : colors.textTertiary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weekly
                      ? s.analyticsWeekOf(fmt.dayShort(point.date))
                      : fmt.dayLong(point.date),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct.clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: AppColors.braweBlue.withValues(
                      alpha: 0.14,
                    ),
                    valueColor: AlwaysStoppedAnimation(
                      first ? AppColors.amber : AppColors.braweBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            fmt.compact(point.value),
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          Text(
            s.analyticsViewersUnit,
            style: TextStyle(color: colors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
