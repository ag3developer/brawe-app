// ============================================================================
// BRAWE CREATOR NETWORK — widgets da jornada (usados no Painel do Creator e
// na página do badge). Visual de "jogo" reaproveitado de quest_visuals.dart.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../domain/models/creator_journey.dart';
import '../../../domain/models/creator_network.dart' hide CreatorTierX;
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../quests/widgets/quest_visuals.dart';
import '../utils/creator_journey_l10n.dart';
import '../utils/creator_l10n.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Peças básicas
// ─────────────────────────────────────────────────────────────────────────────

/// Título de seção com subtítulo opcional.
class JourneySectionTitle extends StatelessWidget {
  const JourneySectionTitle(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(color: c.textSecondary, fontSize: 12.5),
            ),
          ],
        ],
      ),
    );
  }
}

/// Medalha do nível: gradiente + ícone, flutuando e com brilho.
/// [locked] = cinza com cadeado.
class JourneyMedal extends StatelessWidget {
  const JourneyMedal({
    super.key,
    required this.tier,
    this.size = 72,
    this.locked = false,
    this.animate = true,
  });
  final CreatorTier tier;
  final double size;
  final bool locked;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final medal = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: locked
            ? LinearGradient(colors: [c.surfaceHighest, c.border])
            : LinearGradient(
                colors: tier.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
          color: Colors.white.withValues(alpha: locked ? 0.0 : 0.55),
          width: size * 0.04,
        ),
        boxShadow: locked
            ? null
            : [
                BoxShadow(
                  color: tier.color.withValues(alpha: 0.5),
                  blurRadius: size * 0.4,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Icon(
        locked ? LucideIcons.lock : tier.icon,
        size: size * 0.48,
        color: locked ? c.textTertiary : Colors.white,
      ),
    );
    if (locked || !animate) return medal;
    return Floating(
      amplitude: size * 0.05,
      child: ShineSweep(
        borderRadius: BorderRadius.circular(size),
        child: medal,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cartão do nível atual
// ─────────────────────────────────────────────────────────────────────────────

class JourneyLevelCard extends StatelessWidget {
  const JourneyLevelCard({super.key, required this.journey, this.onTap});
  final CreatorJourney journey;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final tier = journey.currentTier;
    final next = journey.nextTier;
    final progress = journey.overallProgress;

    Widget footer;
    if (next == null) {
      footer = _note(context, LucideIcons.crown, s.creatorDashTopLevel);
    } else if (journey.nextTierInviteOnly || progress == null) {
      footer = _note(context, LucideIcons.mail, s.creatorDashInviteNext);
    } else {
      final pct = (progress * 100).round();
      footer = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CountUpText(
            value: pct,
            format: (n) => s.creatorDashOverallProgress(n, next.title(s)),
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          QuestProgressBar(
            value: progress,
            colors: next.gradient,
            background: c.surfaceHighest,
            height: 10,
          ),
        ],
      );
    }

    return GameTile(
      tint: tier.color,
      glow: 0.5,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              JourneyMedal(tier: tier, size: 76),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.creatorDashCurrentLevel.toUpperCase(),
                      style: TextStyle(
                        color: c.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tier.title(s),
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.creatorDashSince(
                        journeyMonthYear(context, journey.creatorSince),
                      ),
                      style: TextStyle(color: c.textSecondary, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(LucideIcons.chevronRight, size: 18, color: c.textTertiary),
            ],
          ),
          const SizedBox(height: 16),
          footer,
        ],
      ),
    );
  }

  Widget _note(BuildContext context, IconData icon, String text) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: c.accentGold),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: c.textSecondary, fontSize: 12.5, height: 1.4),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trilha de níveis (linha do tempo horizontal)
// ─────────────────────────────────────────────────────────────────────────────

class JourneyTrail extends StatefulWidget {
  const JourneyTrail({super.key, required this.journey});
  final CreatorJourney journey;

  @override
  State<JourneyTrail> createState() => _JourneyTrailState();
}

class _JourneyTrailState extends State<JourneyTrail> {
  static const double _nodeW = 96;
  late final ScrollController _ctrl;

  @override
  void initState() {
    super.initState();
    final idx = widget.journey.levels.indexWhere(
      (l) => l.status == JourneyLevelStatus.current,
    );
    _ctrl = ScrollController(
      initialScrollOffset: idx <= 1 ? 0 : (idx - 1) * _nodeW,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final levels = widget.journey.levels;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JourneySectionTitle(s.creatorDashTrailTitle),
        SizedBox(
          height: 150,
          child: ListView.builder(
            controller: _ctrl,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: levels.length,
            itemBuilder: (_, i) => StaggerIn(
              index: i,
              child: _TrailNode(
                level: levels[i],
                width: _nodeW,
                isFirst: i == 0,
                isLast: i == levels.length - 1,
                // linha anterior colorida se este nó já foi alcançado
                reachedLeft: levels[i].status == JourneyLevelStatus.achieved ||
                    levels[i].status == JourneyLevelStatus.current,
                reachedRight: levels[i].status == JourneyLevelStatus.achieved,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrailNode extends StatelessWidget {
  const _TrailNode({
    required this.level,
    required this.width,
    required this.isFirst,
    required this.isLast,
    required this.reachedLeft,
    required this.reachedRight,
  });
  final JourneyLevel level;
  final double width;
  final bool isFirst;
  final bool isLast;
  final bool reachedLeft;
  final bool reachedRight;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final tier = level.tier;
    final done = level.status == JourneyLevelStatus.achieved;
    final current = level.status == JourneyLevelStatus.current;
    final locked = !done && !current;

    String caption;
    Color captionColor = c.textTertiary;
    if (current) {
      caption = s.creatorDashTrailHere;
      captionColor = tier.color;
    } else if (done && level.achievedAt != null) {
      caption = s.creatorDashTrailSince(
        journeyMonthYear(context, level.achievedAt!),
      );
      captionColor = c.textSecondary;
    } else if (level.inviteOnly) {
      caption = s.creatorDashTrailInviteOnly;
    } else {
      caption = s.creatorDashTrailLocked;
    }

    Widget medal = JourneyMedal(
      tier: tier,
      size: current ? 60 : 52,
      locked: locked,
      animate: false,
    );
    if (current) {
      medal = Pulse(minScale: 0.95, maxScale: 1.07, child: medal);
    } else if (done) {
      medal = Stack(
        clipBehavior: Clip.none,
        children: [
          medal,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: c.success,
                shape: BoxShape.circle,
                border: Border.all(color: c.background, width: 2),
              ),
              child: const Icon(LucideIcons.check, size: 11, color: Colors.white),
            ),
          ),
        ],
      );
    }

    Widget line(bool active, bool visible) => Expanded(
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: !visible
                  ? Colors.transparent
                  : (active ? tier.color : c.border),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );

    return SizedBox(
      width: width,
      child: Column(
        children: [
          SizedBox(
            height: 68,
            child: Row(
              children: [
                line(reachedLeft, !isFirst),
                medal,
                line(reachedRight, !isLast),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tier.title(s),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: locked ? c.textTertiary : c.textPrimary,
              fontSize: 12.5,
              fontWeight: current ? FontWeight.w900 : FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: captionColor,
              fontSize: 10.5,
              fontWeight: current ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Metas do próximo nível
// ─────────────────────────────────────────────────────────────────────────────

class JourneyGoalsSection extends StatelessWidget {
  const JourneyGoalsSection({super.key, required this.journey});
  final CreatorJourney journey;

  @override
  Widget build(BuildContext context) {
    final next = journey.nextTier;
    if (next == null || journey.goals.isEmpty) return const SizedBox.shrink();
    final s = S.of(context);
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JourneySectionTitle(
          s.creatorDashGoalsTitle(next.title(s)),
          subtitle: s.creatorDashGoalsHint,
        ),
        GameTile(
          tint: next.color,
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              for (var i = 0; i < journey.goals.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                StaggerIn(
                  index: i,
                  child: _GoalRow(goal: journey.goals[i], tier: next),
                ),
              ],
              if (journey.allGoalsDone) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(LucideIcons.partyPopper, size: 16, color: c.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.creatorDashGoalsAllDone,
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.goal, required this.tier});
  final JourneyGoal goal;
  final CreatorTier tier;

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
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(done ? LucideIcons.check : info.icon,
                  size: 17, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                journeyMetricLabel(s, goal.metric),
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              s.creatorDashGoalOf(
                journeyCompact(goal.current > goal.target ? goal.target : goal.current),
                journeyCompact(goal.target),
              ),
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        QuestProgressBar(
          value: goal.progress,
          colors: done ? [c.success, c.success] : [info.color, tier.color],
          background: c.surfaceHighest,
        ),
        const SizedBox(height: 5),
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

// ─────────────────────────────────────────────────────────────────────────────
// Sua semana
// ─────────────────────────────────────────────────────────────────────────────

class JourneyWeekSection extends StatelessWidget {
  const JourneyWeekSection({super.key, required this.journey});
  final CreatorJourney journey;

  @override
  Widget build(BuildContext context) {
    if (journey.week.isEmpty) return const SizedBox.shrink();
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JourneySectionTitle(
          s.creatorDashWeekTitle,
          subtitle: s.creatorDashWeekSubtitle,
        ),
        LayoutBuilder(
          builder: (context, box) {
            final w = (box.maxWidth - 10) / 2;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < journey.week.length; i++)
                  SizedBox(
                    width: w,
                    child: StaggerIn(
                      index: i,
                      child: _WeekTile(metric: journey.week[i]),
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

class _WeekTile extends StatelessWidget {
  const _WeekTile({required this.metric});
  final JourneyWeekMetric metric;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final info = JourneyMetricInfo.of(metric.metric);
    final route = journeyMetricRoute(metric.metric);

    final Color trendColor;
    final IconData trendIcon;
    final String trendText;
    switch (metric.trend) {
      case JourneyTrend.up:
        trendColor = c.success;
        trendIcon = LucideIcons.trendingUp;
        trendText = s.creatorDashWeekUp(journeyCompact(metric.delta.abs()));
      case JourneyTrend.down:
        trendColor = c.danger;
        trendIcon = LucideIcons.trendingDown;
        trendText = s.creatorDashWeekDown(journeyCompact(metric.delta.abs()));
      case JourneyTrend.flat:
        trendColor = c.textTertiary;
        trendIcon = LucideIcons.equal;
        trendText = s.creatorDashWeekSame;
    }

    return GameTile(
      tint: info.color,
      depth: 4,
      radius: 18,
      padding: const EdgeInsets.all(12),
      onTap: route == null ? null : () => context.push(route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(info.icon, size: 15, color: info.color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  journeyMetricLabel(s, metric.metric, week: true),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          CountUpText(
            value: metric.current,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(trendIcon, size: 13, color: trendColor),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  trendText,
                  style: TextStyle(
                    color: trendColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
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

// ─────────────────────────────────────────────────────────────────────────────
// Benefícios
// ─────────────────────────────────────────────────────────────────────────────

class JourneyBenefitsSection extends StatefulWidget {
  const JourneyBenefitsSection({
    super.key,
    required this.journey,
    this.showNext = true,
    this.collapsedCount = 4,
  });
  final CreatorJourney journey;

  /// Mostra também os benefícios (bloqueados) do próximo nível.
  final bool showNext;
  final int collapsedCount;

  @override
  State<JourneyBenefitsSection> createState() => _JourneyBenefitsSectionState();
}

class _JourneyBenefitsSectionState extends State<JourneyBenefitsSection> {
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final j = widget.journey;
    final active = j.activeBenefits;
    final next = widget.showNext ? j.nextBenefits : const <JourneyBenefit>[];
    final shown = _all ? active : active.take(widget.collapsedCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JourneySectionTitle(s.creatorDashBenefitsTitle),
        for (final b in shown) ...[
          _BenefitTile(benefit: b, locked: false),
          const SizedBox(height: 8),
        ],
        if (active.length > widget.collapsedCount)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _all = !_all),
              child: Text(_all ? s.creatorDashShowLess : s.creatorDashShowAll),
            ),
          ),
        if (next.isNotEmpty && j.nextTier != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(LucideIcons.lock, size: 14, color: c.textTertiary),
              const SizedBox(width: 6),
              Text(
                s.creatorDashBenefitsNextTitle(j.nextTier!.title(s)),
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final b in next) ...[
            _BenefitTile(benefit: b, locked: true),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({required this.benefit, required this.locked});
  final JourneyBenefit benefit;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final t = journeyBenefit(s, benefit.key);
    final color = locked ? c.textTertiary : benefit.tier.color;

    return Opacity(
      opacity: locked ? 0.7 : 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(locked ? LucideIcons.lock : t.icon,
                  size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.title,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (!locked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: c.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            s.creatorDashBenefitActive,
                            style: TextStyle(
                              color: c.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    t.desc,
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Atalhos compactos
// ─────────────────────────────────────────────────────────────────────────────

class JourneyShortcuts extends StatelessWidget {
  const JourneyShortcuts({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final items = <(IconData, String, String, Color)>[
      (LucideIcons.squarePen, s.creatorDashboardQuickCreatePost, '/feed',
          const Color(0xFF10B981)),
      (LucideIcons.radio, s.creatorDashboardQuickGoLive, '/live/start',
          const Color(0xFFEC4899)),
      (LucideIcons.chartColumn, s.creatorDashShortcutAnalytics,
          '/creator/analytics', const Color(0xFF3B82F6)),
      (LucideIcons.settings, s.creatorDashShortcutSettings,
          '/creator/profile-settings', const Color(0xFF94A3B8)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JourneySectionTitle(s.creatorQuickShortcuts),
        Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _Shortcut(item: items[i])),
            ],
          ],
        ),
      ],
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.item});
  final (IconData, String, String, Color) item;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GameTile(
      tint: item.$4,
      depth: 4,
      radius: 16,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      onTap: () => context.push(item.$3),
      child: Column(
        children: [
          Icon(item.$1, size: 21, color: item.$4),
          const SizedBox(height: 6),
          Text(
            item.$2,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
