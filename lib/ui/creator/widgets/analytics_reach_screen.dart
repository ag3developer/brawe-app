import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../view_models/creator_analytics_view_model.dart';
import 'analytics/analytics_async_chart.dart';
import 'analytics/analytics_data.dart';
import 'analytics/analytics_format.dart';
import 'analytics/analytics_top_gifts.dart';
import 'analytics/analytics_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ANALYTICS — ALCANCE E MONETIZAÇÃO
// GET /analytics/earnings   → ganhos/presentes por dia + período anterior
// GET /analytics/top-gifts  → presentes mais recebidos (com imagem)
// ─────────────────────────────────────────────────────────────────────────────

class AnalyticsReachScreen extends ConsumerStatefulWidget {
  const AnalyticsReachScreen({super.key});

  @override
  ConsumerState<AnalyticsReachScreen> createState() =>
      _AnalyticsReachScreenState();
}

class _AnalyticsReachScreenState extends ConsumerState<AnalyticsReachScreen> {
  int _metric = 0; // 0 = ganhos, 1 = presentes

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final fmt = AnalyticsFmt.of(context);
    final period = ref.watch(analyticsPeriodProvider);
    final async = ref.watch(earningsSeriesProvider(period));
    const earnColor = AppColors.success;
    const giftColor = AppColors.amber;

    List<AnalyticsKpi>? kpis;
    final series = async.value;
    if (series != null) {
      final earn = series.val('earnings');
      final gifts = series.val('gifts_count');
      final pEarn = series.val('previous_earnings');
      final pGifts = series.val('previous_gifts_count');
      final avg = gifts > 0 ? earn / gifts : 0.0;
      final pAvg = pGifts > 0 ? pEarn / pGifts : 0.0;
      kpis = [
        AnalyticsKpi(
          icon: LucideIcons.dollarSign,
          color: earnColor,
          label: s.analyticsEarningsLabel,
          value: earn,
          format: fmt.moneyCompact,
          deltaPct: series.pct('earnings_change_pct'),
        ),
        AnalyticsKpi(
          icon: LucideIcons.gift,
          color: giftColor,
          label: s.analyticsGiftsLabel,
          value: gifts,
          format: fmt.compact,
          deltaPct: series.pct('gifts_change_pct'),
        ),
        AnalyticsKpi(
          icon: LucideIcons.sparkles,
          color: AppColors.braweBlue,
          label: s.analyticsAvgPerGift,
          value: avg,
          format: fmt.money,
          deltaPct: pAvg > 0 ? (avg - pAvg) / pAvg * 100 : null,
        ),
      ];
    }

    final isMoney = _metric == 0;
    final color = isMoney ? earnColor : giftColor;
    final label = isMoney ? s.analyticsEarningsLabel : s.analyticsGiftsLabel;

    return AnalyticsPage(
      title: s.analyticsReachTitle,
      onRefresh: () async {
        ref.invalidate(earningsSeriesProvider(period));
        ref.invalidate(topGiftsByPeriodProvider(period));
        await Future.wait([
          ref.read(earningsSeriesProvider(period).future),
          ref.read(topGiftsByPeriodProvider(period).future),
        ]).catchError((_) => <Object>[]);
      },
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4, bottom: 14),
          child: AnalyticsPeriodSegment(),
        ),
        AnalyticsKpiGrid(kpis: kpis, skeletonCount: 3),
        const SizedBox(height: 16),
        AnalyticsChartPanel(
          title: isMoney
              ? s.analyticsEarningsChartTitle
              : s.analyticsGiftsChartTitle,
          toolbar: AnalyticsChipToggle(
            labels: [s.analyticsEarningsLabel, s.analyticsGiftsLabel],
            selected: _metric,
            color: color,
            onChanged: (i) => setState(() => _metric = i),
          ),
          builder: (compare) => AnalyticsAsyncChart(
            async: async,
            onRetry: () => ref.invalidate(earningsSeriesProvider(period)),
            builder: (data) => seriesLineChart(
              context,
              data,
              label: label,
              color: color,
              useSecond: !isMoney,
              compare: compare,
              format: isMoney ? fmt.money : fmt.integer,
            ),
          ),
          legendBuilder: (compare) =>
              seriesLegend(context, [(color: color, label: label)], compare),
        ),
        AnalyticsTopGifts(period: period),
      ],
    );
  }
}
