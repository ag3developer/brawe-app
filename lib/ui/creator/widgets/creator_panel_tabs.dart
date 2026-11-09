import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/feature_flags.dart';
import '../../../data/repositories/creator_agency_repository.dart';
import '../../../domain/models/creator_journey.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../utils/creator_journey_l10n.dart';
import '../utils/creator_l10n.dart';
import '../view_models/creator_agency_providers.dart';
import '../view_models/creator_journey_provider.dart';
import 'agency/agency_widgets.dart';
import 'creator_journey_widgets.dart' show JourneyBenefitsSection;
import 'creator_panel_scope.dart';
import 'creator_state_views.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Abas Início · Desempenho · Benefícios do painel do criador.
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _refreshJourney(WidgetRef ref) async {
  ref.invalidate(creatorJourneyProvider);
  try {
    await ref.read(creatorJourneyProvider.future);
  } catch (_) {}
}

/// Casca comum das abas baseadas na jornada: carregando / erro / dados.
class _JourneyTab extends ConsumerWidget {
  const _JourneyTab({
    required this.storageKey,
    required this.builder,
    this.extraRefresh,
  });
  final String storageKey;
  final Widget Function(BuildContext, CreatorJourney) builder;
  final Future<void> Function(WidgetRef)? extraRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final async = ref.watch(creatorJourneyProvider);
    Future<void> refresh() async {
      await extraRefresh?.call(ref);
      await _refreshJourney(ref);
    }

    return PanelTabScroll(
      storageKey: storageKey,
      onRefresh: refresh,
      slivers: [
        async.when(
          loading: () => const SliverToBoxAdapter(
            child: AgencySkeleton(blocks: [72, 150, 140]),
          ),
          error: (_, _) => SliverFillRemaining(
            hasScrollBody: false,
            child: CreatorErrorView(
              message: s.creatorDashErrorTitle,
              onRetry: refresh,
            ),
          ),
          data: (j) => SliverToBoxAdapter(child: builder(context, j)),
        ),
      ],
    );
  }
}

// ── Início ───────────────────────────────────────────────────────────────────

class PanelHomeTab extends StatelessWidget {
  const PanelHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return _JourneyTab(
      storageKey: 'panel-home',
      extraRefresh: (ref) async => ref.invalidate(creatorAgencyProvider),
      builder: (context, j) => AgencyColumns(
        left: [
          const PanelShortcuts(),
          PanelNextLevelCard(journey: j),
        ],
        right: [
          if (j.goals.isNotEmpty && j.nextTier != null)
            PanelGoalsCard(journey: j),
          const PanelAgenciesRow(),
        ],
      ),
    );
  }
}

class PanelShortcuts extends StatelessWidget {
  const PanelShortcuts({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final items = <(IconData, String, String, Color)>[
      (
        LucideIcons.radio,
        s.creatorDashboardQuickGoLive,
        '/live/start',
        c.accentPink,
      ),
      (
        LucideIcons.squarePen,
        s.creatorDashboardQuickCreatePost,
        '/feed',
        c.accentGold,
      ),
      // Monetização é uma aba deste mesmo painel: troca de aba em vez de abrir outra tela.
      if (kEnableMonetization)
        (
          LucideIcons.gem,
          s.creatorPanelTabMonetization,
          '/creator/dashboard?tab=monetization',
          c.success,
        ),
      (
        LucideIcons.chartColumn,
        s.creatorDashShortcutAnalytics,
        '/creator/analytics',
        c.accentPrimary,
      ),
    ];
    return AgencyBox(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final it in items)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  final tab = Uri.parse(it.$3).queryParameters['tab'];
                  final select = CreatorPanelScope.selectTabOf(context);
                  if (tab != null && select != null && select(tab)) return;
                  context.push(it.$3);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: it.$4.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(it.$1, size: 19, color: it.$4),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        it.$2,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PanelNextLevelCard extends StatelessWidget {
  const PanelNextLevelCard({super.key, required this.journey});
  final CreatorJourney journey;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final next = journey.nextTier;
    final progress = journey.overallProgress;
    final shown = next ?? journey.currentTier;
    final pct = progress == null ? null : (progress * 100).floor();

    final String note;
    if (next == null) {
      note = s.creatorDashTopLevel;
    } else if (journey.nextTierInviteOnly || progress == null) {
      note = s.creatorDashInviteNext;
    } else {
      note = s.creatorDashOverallProgress(pct!, next.title(s));
    }

    return AgencyBox(
      onTap: () => context.push('/creator/badge'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: shown.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(shown.icon, size: 19, color: shown.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      next == null
                          ? s.creatorDashCurrentLevel
                          : s.creatorPanelNextLevel,
                      style: AgencyText.caption(context),
                    ),
                    Text(
                      shown.title(s),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AgencyText.title(context).copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
              if (pct != null && next != null) ...[
                const SizedBox(width: 8),
                Text(
                  '$pct%',
                  style: AgencyText.number(
                    context,
                    size: 20,
                    color: shown.color,
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Icon(LucideIcons.chevronRight, size: 18, color: c.textTertiary),
            ],
          ),
          if (progress != null && next != null) ...[
            const SizedBox(height: 12),
            AgencyProgressBar(value: progress, color: shown.color),
          ],
          const SizedBox(height: 10),
          Text(note, style: AgencyText.caption(context)),
          const SizedBox(height: 12),
          const AgencyDivider(),
          const SizedBox(height: 12),
          _CompactTrail(levels: journey.levels),
        ],
      ),
    );
  }
}

/// Trilha compacta: um ponto por nível (conquistado / atual / próximo / bloqueado).
class _CompactTrail extends StatelessWidget {
  const _CompactTrail({required this.levels});
  final List<JourneyLevel> levels;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    if (levels.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < levels.length; i++)
            SizedBox(
              width: 84,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _line(
                          i > 0 && _reached(levels[i]),
                          c.accentPrimary,
                          c.border,
                          show: i > 0,
                        ),
                      ),
                      _dot(levels[i], c),
                      Expanded(
                        child: _line(
                          _reached(levels[i]) &&
                              levels[i].status != JourneyLevelStatus.current,
                          c.accentPrimary,
                          c.border,
                          show: i < levels.length - 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    levels[i].tier.title(s),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1.2,
                      color: levels[i].status == JourneyLevelStatus.current
                          ? c.textPrimary
                          : c.textTertiary,
                      fontSize: 11,
                      fontWeight: levels[i].status == JourneyLevelStatus.current
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _reached(JourneyLevel l) =>
      l.status == JourneyLevelStatus.achieved ||
      l.status == JourneyLevelStatus.current;

  Widget _line(bool on, Color onColor, Color offColor, {required bool show}) =>
      show
      ? Container(height: 2, color: on ? onColor : offColor)
      : const SizedBox(height: 2);

  Widget _dot(JourneyLevel l, BraweColors c) {
    final color = l.tier.color;
    switch (l.status) {
      case JourneyLevelStatus.achieved:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const Icon(LucideIcons.check, size: 12, color: Colors.white),
        );
      case JourneyLevelStatus.current:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            color: c.surface,
          ),
        );
      case JourneyLevelStatus.next:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        );
      case JourneyLevelStatus.locked:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.surfaceHighest,
          ),
          child: Icon(LucideIcons.lock, size: 10, color: c.textTertiary),
        );
    }
  }
}

class PanelGoalsCard extends StatelessWidget {
  const PanelGoalsCard({super.key, required this.journey});
  final CreatorJourney journey;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final next = journey.nextTier!;
    return AgencyBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AgencyBoxTitle(
            icon: LucideIcons.target,
            text: s.creatorDashGoalsTitle(next.title(s)),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < journey.goals.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _GoalLine(goal: journey.goals[i]),
          ],
          if (journey.allGoalsDone) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(LucideIcons.circleCheck, size: 15, color: c.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.creatorDashGoalsAllDone,
                    style: AgencyText.caption(context),
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

class _GoalLine extends StatelessWidget {
  const _GoalLine({required this.goal});
  final JourneyGoal goal;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final info = JourneyMetricInfo.of(goal.metric);
    final done = goal.done;
    final color = done ? c.success : info.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              done ? LucideIcons.circleCheck : info.icon,
              size: 15,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                journeyMetricLabel(s, goal.metric),
                style: AgencyText.body(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              s.creatorDashGoalOf(
                journeyCompact(
                  goal.current > goal.target ? goal.target : goal.current,
                ),
                journeyCompact(goal.target),
              ),
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                fontFeatures: kTabularFigures,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AgencyProgressBar(value: goal.progress, color: color),
        const SizedBox(height: 4),
        Text(
          done
              ? s.creatorDashGoalDone
              : journeyRemaining(s, goal.metric, goal.remaining),
          style: TextStyle(
            color: done ? c.success : c.textTertiary,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Sem agência nem convites: linha discreta "Agências — aberto a convites".
class PanelAgenciesRow extends ConsumerStatefulWidget {
  const PanelAgenciesRow({super.key});
  @override
  ConsumerState<PanelAgenciesRow> createState() => _PanelAgenciesRowState();
}

class _PanelAgenciesRowState extends ConsumerState<PanelAgenciesRow> {
  bool? _local;
  bool _busy = false;

  Future<void> _toggle(bool v) async {
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _local = v;
      _busy = true;
    });
    try {
      await ref.read(creatorAgencyRepositoryProvider).setOpenToAgencies(v);
      ref.invalidate(creatorAgencyProvider);
    } catch (_) {
      if (!mounted) return;
      setState(() => _local = !v);
      messenger.showSnackBar(SnackBar(content: Text(s.creatorPanelOpenError)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final state = ref.watch(creatorAgencyProvider).value;
    if (state == null || state.link != null || state.pendingInvites.isNotEmpty)
      return const SizedBox.shrink();
    final value = _local ?? state.openToAgencies;
    return AgencyBox(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Icon(LucideIcons.building2, size: 18, color: c.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.creatorPanelAgenciesRow,
                  style: AgencyText.title(context),
                ),
                Text(
                  s.creatorPanelAgenciesOpen,
                  style: AgencyText.caption(context),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: s.creatorPanelHowItWorks,
            icon: Icon(LucideIcons.info, size: 18, color: c.textTertiary),
            onPressed: () => showAgenciesHowSheet(context),
          ),
          Switch(value: value, onChanged: _busy ? null : _toggle),
        ],
      ),
    );
  }
}

Future<void> showAgenciesHowSheet(BuildContext context) {
  final s = S.of(context);
  final c = context.colors;
  final points = <(IconData, String)>[
    (LucideIcons.building2, s.agencyEmptyBody),
    (LucideIcons.wallet, s.agencyInfoEarningsBody),
    (LucideIcons.handshake, s.agencyInfoOneBody),
    (LucideIcons.megaphone, s.agencyOpenBody),
    (LucideIcons.doorOpen, s.agencyExitRuleFree),
    (LucideIcons.handshake, s.agencyExitRuleAgreement),
    (LucideIcons.shieldCheck, s.agencyExitRuleAbuse),
  ];
  return showModalBottomSheet<void>(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) => SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        24 + MediaQuery.paddingOf(ctx).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.creatorPanelHowTitle,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          for (final p in points)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(p.$1, size: 18, color: c.accentPrimary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(p.$2, style: AgencyText.body(context))),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

// ── Desempenho ───────────────────────────────────────────────────────────────

class PanelPerformanceTab extends StatelessWidget {
  const PanelPerformanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return _JourneyTab(
      storageKey: 'panel-performance',
      builder: (context, j) => AgencyColumns(
        left: [PanelWeekCard(journey: j)],
        right: const [PanelAnalyticsEntry()],
      ),
    );
  }
}

class PanelWeekCard extends StatelessWidget {
  const PanelWeekCard({super.key, required this.journey});
  final CreatorJourney journey;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AgencyBox(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AgencyBoxTitle(icon: LucideIcons.gauge, text: s.creatorDashWeekTitle),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              s.creatorDashWeekSubtitle,
              style: AgencyText.caption(context),
            ),
          ),
          const SizedBox(height: 6),
          if (journey.week.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                s.agencyChartEmpty,
                style: AgencyText.caption(context),
              ),
            )
          else
            for (var i = 0; i < journey.week.length; i++) ...[
              if (i > 0) const AgencyDivider(),
              _WeekRow(metric: journey.week[i]),
            ],
        ],
      ),
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({required this.metric});
  final JourneyWeekMetric metric;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final info = JourneyMetricInfo.of(metric.metric);
    final route = journeyMetricRoute(metric.metric);
    final (IconData icon, Color col, String text) = switch (metric.trend) {
      JourneyTrend.up => (
        LucideIcons.trendingUp,
        c.success,
        '+${journeyCompact(metric.delta.abs())}',
      ),
      JourneyTrend.down => (
        LucideIcons.trendingDown,
        c.danger,
        '-${journeyCompact(metric.delta.abs())}',
      ),
      JourneyTrend.flat => (
        LucideIcons.equal,
        c.textTertiary,
        s.creatorDashWeekSameShort,
      ),
    };
    return InkWell(
      onTap: route == null ? null : () => context.push(route),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(info.icon, size: 17, color: info.color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  journeyMetricLabel(s, metric.metric, week: true),
                  style: AgencyText.body(context),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                journeyCompact(metric.current),
                style: AgencyText.number(context, size: 17),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(icon, size: 13, color: col),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: col,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFeatures: kTabularFigures,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PanelAnalyticsEntry extends StatelessWidget {
  const PanelAnalyticsEntry({super.key});
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    return AgencyBox(
      onTap: () => context.push('/creator/analytics'),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.accentPrimary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              LucideIcons.chartColumn,
              size: 20,
              color: c.accentPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.creatorPanelAnalyticsTitle,
                  style: AgencyText.title(context),
                ),
                Text(
                  s.creatorPanelAnalyticsBody,
                  style: AgencyText.caption(context),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 18, color: c.textTertiary),
        ],
      ),
    );
  }
}

// ── Benefícios ───────────────────────────────────────────────────────────────

class PanelBenefitsTab extends StatelessWidget {
  const PanelBenefitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return _JourneyTab(
      storageKey: 'panel-benefits',
      builder: (context, j) =>
          AgencyColumns(left: [JourneyBenefitsSection(journey: j)]),
    );
  }
}
