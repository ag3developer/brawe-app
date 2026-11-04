import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../quests/widgets/quest_visuals.dart';
import '../view_models/creator_analytics_view_model.dart';
import 'analytics/analytics_charts.dart';
import 'analytics/analytics_data.dart';
import 'analytics/analytics_format.dart';
import 'analytics/analytics_top_gifts.dart';
import 'analytics/analytics_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ANALYTICS — VISÃO GERAL (aba do hub)
// Um cartão por métrica, com mini-gráfico e variação vs. período anterior.
// Tocar num cartão troca para a aba correspondente.
// ─────────────────────────────────────────────────────────────────────────────

/// Índices das abas do hub.
class AnalyticsTabs {
  static const overview = 0;
  static const followers = 1;
  static const audience = 2;
  static const lives = 3;
  static const earnings = 4;
  static const keys = ['overview', 'followers', 'audience', 'lives', 'earnings'];

  static int fromKey(String? key) {
    final i = keys.indexOf(key ?? '');
    return i < 0 ? 0 : i;
  }
}

class AnalyticsOverviewBody extends ConsumerWidget {
  final ValueChanged<int> onSelectTab;
  const AnalyticsOverviewBody({super.key, required this.onSelectTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final fmt = AnalyticsFmt.of(context);
    final period = ref.watch(analyticsPeriodProvider);
    final followers = ref.watch(followersSeriesProvider(period));
    final viewers = ref.watch(viewersSeriesProvider(period));
    final lives = ref.watch(livesSeriesProvider(period));
    final earnings = ref.watch(earningsSeriesProvider(period));

    List<double> spark(AnalyticsSeries d, {bool second = false}) => [
      for (final p in d.current) second ? (p.second ?? 0) : p.value,
    ];

    final cards = <Widget>[
      _OverviewCard(
        async: followers,
        icon: LucideIcons.users,
        color: context.colors.accentPrimary,
        label: s.analyticsFollowersCount,
        value: (d) => d.val('total'),
        format: fmt.compact,
        delta: (d) => d.pct('growth_pct'),
        spark: (d) => spark(d),
        onTap: () => onSelectTab(AnalyticsTabs.followers),
        onRetry: () => ref.invalidate(followersSeriesProvider(period)),
      ),
      _OverviewCard(
        async: viewers,
        icon: LucideIcons.eye,
        color: AppColors.braweSky,
        label: s.analyticsViewersTotalViewers,
        value: (d) => d.val('viewers'),
        format: fmt.compact,
        delta: (d) => d.pct('viewers_change_pct'),
        spark: (d) => spark(d),
        onTap: () => onSelectTab(AnalyticsTabs.audience),
        onRetry: () => ref.invalidate(viewersSeriesProvider(period)),
      ),
      _OverviewCard(
        async: lives,
        icon: LucideIcons.radio,
        color: AppColors.hotPink,
        label: s.analyticsLivesKpiTotal,
        value: (d) => d.val('lives'),
        format: fmt.integer,
        delta: (d) => d.pct('lives_change_pct'),
        spark: (d) => spark(d),
        onTap: () => onSelectTab(AnalyticsTabs.lives),
        onRetry: () => ref.invalidate(livesSeriesProvider(period)),
      ),
      _OverviewCard(
        async: lives,
        icon: LucideIcons.clock,
        color: AppColors.braweOrange,
        label: s.analyticsLivesMinutesLabel,
        value: (d) => d.val('minutes'),
        format: (v) {
          final t = v.round();
          return t < 60
              ? s.analyticsMinutesShort(t.toString())
              : s.analyticsHoursMinutes((t ~/ 60).toString(), (t % 60).toString());
        },
        delta: (d) => d.pct('minutes_change_pct'),
        spark: (d) => spark(d, second: true),
        onTap: () => onSelectTab(AnalyticsTabs.lives),
        onRetry: () => ref.invalidate(livesSeriesProvider(period)),
      ),
      _OverviewCard(
        async: earnings,
        icon: LucideIcons.dollarSign,
        color: AppColors.success,
        label: s.analyticsEarningsLabel,
        value: (d) => d.val('earnings'),
        format: fmt.moneyCompact,
        delta: (d) => d.pct('earnings_change_pct'),
        spark: (d) => spark(d),
        onTap: () => onSelectTab(AnalyticsTabs.earnings),
        onRetry: () => ref.invalidate(earningsSeriesProvider(period)),
      ),
      _OverviewCard(
        async: earnings,
        icon: LucideIcons.gift,
        color: AppColors.amber,
        label: s.analyticsGiftsLabel,
        value: (d) => d.val('gifts_count'),
        format: fmt.compact,
        delta: (d) => d.pct('gifts_change_pct'),
        spark: (d) => spark(d, second: true),
        onTap: () => onSelectTab(AnalyticsTabs.earnings),
        onRetry: () => ref.invalidate(earningsSeriesProvider(period)),
      ),
    ];

    return AnalyticsTabScroll(
      onRefresh: () async {
        ref.invalidate(followersSeriesProvider(period));
        ref.invalidate(viewersSeriesProvider(period));
        ref.invalidate(livesSeriesProvider(period));
        ref.invalidate(earningsSeriesProvider(period));
        ref.invalidate(topGiftsByPeriodProvider(period));
        await Future.wait([
          ref.read(followersSeriesProvider(period).future),
          ref.read(viewersSeriesProvider(period).future),
          ref.read(livesSeriesProvider(period).future),
          ref.read(earningsSeriesProvider(period).future),
        ]).then((_) {}, onError: (_) {});
      },
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            s.analyticsOverviewSeeDetails,
            style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
          ),
        ),
        for (var i = 0; i < cards.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: cards[i]),
                  const SizedBox(width: 10),
                  Expanded(child: cards[i + 1]),
                ],
              ),
            ),
          ),
        AnalyticsTopGifts(
          period: period,
          featuredOnly: true,
          title: s.analyticsOverviewTopGift,
          onTap: () => onSelectTab(AnalyticsTabs.earnings),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final AsyncValue<AnalyticsSeries> async;
  final IconData icon;
  final Color color;
  final String label;
  final double Function(AnalyticsSeries) value;
  final String Function(double) format;
  final double? Function(AnalyticsSeries) delta;
  final List<double> Function(AnalyticsSeries) spark;
  final VoidCallback onTap;
  final VoidCallback onRetry;

  const _OverviewCard({
    required this.async,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.format,
    required this.delta,
    required this.spark,
    required this.onTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final d = async.value;
    if (d == null) {
      if (async.hasError) {
        return GameTile(
          tint: color,
          depth: 4,
          radius: 18,
          onTap: onRetry,
          child: Center(
            child: Icon(LucideIcons.refreshCw, size: 18, color: colors.textTertiary),
          ),
        );
      }
      return const AnalyticsSkeleton(height: 132, radius: 18);
    }
    return GameTile(
      tint: color,
      depth: 4,
      radius: 18,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 13, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: CountUpText(
              value: (value(d) * 100).round(),
              format: (n) => format(n / 100),
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnalyticsDelta(pct: delta(d)),
          const SizedBox(height: 6),
          AnalyticsSparkline(values: spark(d), color: color),
        ],
      ),
    );
  }
}
