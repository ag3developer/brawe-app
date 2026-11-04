import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../view_models/creator_analytics_view_model.dart';
import 'analytics/analytics_async_chart.dart';
import 'analytics/analytics_data.dart';
import 'analytics/analytics_format.dart';
import 'analytics/analytics_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ANALYTICS — SEGUIDORES / CRESCIMENTO
// GET /analytics/followers  → novos por dia + acumulado + período anterior
// GET /social/stats/:userId → seguindo, lives (resumo da conta)
// ─────────────────────────────────────────────────────────────────────────────

class AnalyticsFollowersBody extends ConsumerStatefulWidget {
  const AnalyticsFollowersBody({super.key});

  @override
  ConsumerState<AnalyticsFollowersBody> createState() =>
      _AnalyticsFollowersBodyState();
}

class _AnalyticsFollowersBodyState
    extends ConsumerState<AnalyticsFollowersBody> {
  int _metric = 0; // 0 = acumulado, 1 = novos por dia

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final fmt = AnalyticsFmt.of(context);
    final colors = context.colors;
    final period = ref.watch(analyticsPeriodProvider);
    final async = ref.watch(followersSeriesProvider(period));
    final social = ref.watch(creatorSocialStatsProvider);
    final color = colors.accentPrimary;

    List<AnalyticsKpi>? kpis;
    final data = async.value;
    if (data != null) {
      kpis = [
        AnalyticsKpi(
          icon: LucideIcons.users,
          color: color,
          label: s.analyticsFollowersCount,
          value: data.val('total'),
          format: fmt.compact,
          deltaPct: data.pct('growth_pct'),
        ),
        AnalyticsKpi(
          icon: LucideIcons.userPlus,
          color: AppColors.success,
          label: s.analyticsFollowersNew,
          value: data.val('new_followers'),
          format: fmt.compact,
          deltaPct: data.pct('new_change_pct'),
        ),
      ];
    }

    final accumulated = _metric == 0;
    final label = accumulated
        ? s.analyticsFollowersChartTotal
        : s.analyticsFollowersChartNew;

    return AnalyticsTabScroll(
      onRefresh: () async {
        ref.invalidate(followersSeriesProvider(period));
        ref.invalidate(creatorSocialStatsProvider);
        await ref
            .read(followersSeriesProvider(period).future)
            .then((_) {}, onError: (_) {});
      },
      children: [
        AnalyticsKpiGrid(kpis: kpis),
        const SizedBox(height: 16),
        AnalyticsChartPanel(
          title: label,
          canCompare: !accumulated,
          toolbar: AnalyticsChipToggle(
            labels: [
              s.analyticsFollowersChartTotal,
              s.analyticsFollowersChartNew,
            ],
            selected: _metric,
            color: color,
            onChanged: (i) => setState(() => _metric = i),
          ),
          builder: (compare) => AnalyticsAsyncChart(
            async: async,
            onRetry: () => ref.invalidate(followersSeriesProvider(period)),
            // vazio = nenhum seguidor no início e nenhum novo no período
            isEmpty: (d) => accumulated ? d.emptyFor() : d.emptyFor(second: true),
            emptyMessage: accumulated
                ? s.analyticsEmptyFollowersTotal
                : s.analyticsEmptyFollowersNew(analyticsRangeLabel(s, period)),
            builder: (d) => accumulated
                ? seriesLineChart(
                    context,
                    d,
                    label: label,
                    color: color,
                    integer: true,
                    format: fmt.integer,
                  )
                : seriesBarChart(
                    context,
                    d,
                    label: label,
                    color: AppColors.success,
                    useSecond: true,
                    compare: compare,
                    format: fmt.integer,
                  ),
          ),
          legendBuilder: (compare) => seriesLegend(context, [
            (color: accumulated ? color : AppColors.success, label: label),
          ], compare && !accumulated),
        ),
        AnalyticsSectionTitle(title: s.analyticsFollowersSummaryTitle),
        social.when(
          loading: () => const AnalyticsSkeleton(height: 190, radius: 18),
          error: (_, _) => AnalyticsErrorView(
            height: 150,
            onRetry: () => ref.invalidate(creatorSocialStatsProvider),
          ),
          data: (d) => _Summary(data: d),
        ),
        AnalyticsSectionTitle(title: s.analyticsFollowersTipsTitle),
        const _Tips(),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  final Map<String, dynamic> data;
  const _Summary({required this.data});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final fmt = AnalyticsFmt.of(context);
    final followers = (data['followers_count'] as num?)?.toInt() ?? 0;
    final following = (data['following_count'] as num?)?.toInt() ?? 0;
    final lives = (data['total_lives'] as num?)?.toInt() ?? 0;
    final rows = [
      (
        LucideIcons.users,
        s.analyticsFollowersSummaryFollowers,
        fmt.integer(followers),
        context.colors.accentPrimary,
      ),
      (
        LucideIcons.userCheck,
        s.analyticsFollowersSummaryFollowing,
        fmt.integer(following),
        AppColors.braweSky,
      ),
      (
        LucideIcons.radio,
        s.analyticsFollowersSummaryLives,
        fmt.integer(lives),
        AppColors.hotPink,
      ),
      (
        LucideIcons.activity,
        s.analyticsFollowersSummaryRatio,
        lives > 0 ? fmt.axis(double.parse((followers / lives).toStringAsFixed(1))) : '—',
        AppColors.success,
      ),
    ];
    return AnalyticsCard(
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 18, color: context.colors.divider),
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: rows[i].$4.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(rows[i].$1, size: 15, color: rows[i].$4),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rows[i].$2,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  rows[i].$3,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Tips extends StatelessWidget {
  const _Tips();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final tips = [
      (LucideIcons.radio, s.analyticsFollowersTip1Title, s.analyticsFollowersTip1Subtitle),
      (LucideIcons.messageCircle, s.analyticsFollowersTip2Title, s.analyticsFollowersTip2Subtitle),
      (LucideIcons.share2, s.analyticsFollowersTip3Title, s.analyticsFollowersTip3Subtitle),
    ];
    return Column(
      children: [
        for (final t in tips)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AnalyticsCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(t.$1, size: 18, color: AppColors.braweBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.$2,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          t.$3,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 11.5,
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
    );
  }
}
