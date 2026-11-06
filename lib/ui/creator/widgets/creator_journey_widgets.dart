// ============================================================================
// BRAWE CREATOR NETWORK — widgets da jornada (medalha, metas e benefícios;
// usados no painel do creator e na página do badge).
// ============================================================================

import 'package:flutter/material.dart';
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
              child: Icon(
                done ? LucideIcons.check : info.icon,
                size: 17,
                color: color,
              ),
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
                journeyCompact(
                  goal.current > goal.target ? goal.target : goal.current,
                ),
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
              Expanded(
                child: Text(
                  s.creatorDashBenefitsNextTitle(j.nextTier!.title(s)),
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
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
              child: Icon(
                locked ? LucideIcons.lock : t.icon,
                size: 18,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        t.title,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (!locked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
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
