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
            isEmpty: (d) =>
                accumulated ? d.emptyFor() : d.emptyFor(second: true),
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
    // Seguidores já aparecem no topo: aqui só o que complementa.
    return AnalyticsKpiGrid(
      kpis: [
        AnalyticsKpi(
          icon: LucideIcons.userCheck,
          color: AppColors.braweSky,
          label: s.analyticsFollowersSummaryFollowing,
          value: following.toDouble(),
          format: (v) => fmt.integer(v.round()),
          hasDelta: false,
        ),
        AnalyticsKpi(
          icon: LucideIcons.radio,
          color: AppColors.hotPink,
          label: s.analyticsFollowersSummaryLives,
          value: lives.toDouble(),
          format: (v) => fmt.integer(v.round()),
          hasDelta: false,
        ),
        AnalyticsKpi(
          icon: LucideIcons.activity,
          color: AppColors.success,
          label: s.analyticsFollowersSummaryRatio,
          value: lives > 0 ? followers / lives : 0,
          format: (v) =>
              lives > 0 ? fmt.axis(double.parse(v.toStringAsFixed(1))) : '—',
          hasDelta: false,
        ),
      ],
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
      (
        LucideIcons.radio,
        s.analyticsFollowersTip1Title,
        s.analyticsFollowersTip1Subtitle,
      ),
      (
        LucideIcons.messageCircle,
        s.analyticsFollowersTip2Title,
        s.analyticsFollowersTip2Subtitle,
      ),
      (
        LucideIcons.share2,
        s.analyticsFollowersTip3Title,
        s.analyticsFollowersTip3Subtitle,
      ),
    ];
    return AnalyticsCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          for (var k = 0; k < tips.length; k++) ...[
            if (k > 0) Divider(height: 1, indent: 30, color: colors.border),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Builder(
                builder: (_) {
                  final t = tips[k];
                  return Row(
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
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
