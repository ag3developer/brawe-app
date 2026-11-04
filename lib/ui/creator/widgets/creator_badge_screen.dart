import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../domain/models/creator_journey.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../quests/widgets/quest_visuals.dart';
import '../utils/creator_journey_l10n.dart';
import '../utils/creator_l10n.dart';
import '../view_models/creator_journey_provider.dart';
import '../view_models/creator_network_view_model.dart';
import 'creator_journey_widgets.dart';
import 'creator_state_views.dart';

/// Página do badge: medalha animada, nome traduzido, data de conquista,
/// benefícios ativos e chamada para o próximo nível.
class CreatorBadgeScreen extends ConsumerWidget {
  const CreatorBadgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final profileAsync = ref.watch(myCreatorProfileProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: Text(s.creatorBadgeScreenTitle),
      ),
      body: profileAsync.when(
        loading: () => const CreatorLoadingView(),
        error: (e, _) => CreatorErrorView(
          message: s.creatorDashErrorTitle,
          onRetry: () => ref.invalidate(myCreatorProfileProvider),
        ),
        data: (profile) {
          if (profile == null) {
            return CreatorEmptyState(
              icon: Icons.workspace_premium_outlined,
              title: s.creatorBadgeLocked,
              subtitle: s.creatorBadgeScreenSubtitle,
              actionLabel: s.creatorActionApplyNow,
              onAction: () => context.go('/creator/apply'),
            );
          }
          final async = ref.watch(creatorJourneyProvider);
          return async.when(
            loading: () => const CreatorLoadingView(),
            error: (e, _) => CreatorErrorView(
              message: s.creatorDashErrorTitle,
              onRetry: () => ref.invalidate(creatorJourneyProvider),
            ),
            data: (journey) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(creatorJourneyProvider);
                try {
                  await ref.read(creatorJourneyProvider.future);
                } catch (_) {}
              },
              child: _BadgeBody(journey: journey),
            ),
          );
        },
      ),
    );
  }
}

class _BadgeBody extends StatelessWidget {
  const _BadgeBody({required this.journey});
  final CreatorJourney journey;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final tier = journey.currentTier;
    final earned = journey.achievedAt(tier) ?? journey.creatorSince;
    final badges = journey.badges.where((b) => b.active).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Center(
          child: Column(
            children: [
              Sparkles(
                color: tier.color,
                count: 8,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: JourneyMedal(tier: tier, size: 150),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                tier.title(s),
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: tier.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.calendarCheck,
                        size: 13, color: tier.color),
                    const SizedBox(width: 6),
                    Text(
                      s.creatorJourneyBadgeEarnedOn(
                        journeyFullDate(context, earned),
                      ),
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                tier.body(s),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        JourneyBenefitsSection(journey: journey, showNext: false),
        if (badges.isNotEmpty) ...[
          const SizedBox(height: 22),
          JourneySectionTitle(s.creatorJourneyBadgeAllTitle),
          for (final b in badges) ...[
            _BadgeRow(badge: b),
            const SizedBox(height: 8),
          ],
        ],
        if (journey.nextTier != null) ...[
          const SizedBox(height: 22),
          JourneySectionTitle(s.creatorJourneyBadgeNextTitle),
          _NextLevelCard(journey: journey),
          const SizedBox(height: 16),
          JourneyGoalsSection(journey: journey),
        ],
        if (!context.canPop()) ...[
          const SizedBox(height: 22),
          OutlinedButton.icon(
            icon: const Icon(LucideIcons.layoutDashboard, size: 18),
            label: Text(s.creatorJourneyBadgeOpenDashboard),
            onPressed: () => context.go('/creator/dashboard'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ],
    );
  }
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.badge});
  final JourneyBadge badge;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final tier = badge.tier;
    final color = tier?.color ?? c.accentPrimary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Icon(tier?.icon ?? LucideIcons.badgeCheck, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  journeyBadgeName(s, badge.badgeType),
                  style: TextStyle(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
                if (badge.grantedAt != null)
                  Text(
                    s.creatorJourneyBadgeEarnedOn(
                      journeyFullDate(context, badge.grantedAt!),
                    ),
                    style: TextStyle(color: c.textSecondary, fontSize: 11.5),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: c.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              s.creatorBadgeActive,
              style: TextStyle(
                color: c.success,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Próximo nível: medalha bloqueada + progresso geral.
class _NextLevelCard extends StatelessWidget {
  const _NextLevelCard({required this.journey});
  final CreatorJourney journey;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final next = journey.nextTier!;
    final progress = journey.overallProgress;

    return GameTile(
      tint: next.color,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          JourneyMedal(tier: next, size: 56, locked: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  next.title(s),
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                if (progress != null && !journey.nextTierInviteOnly) ...[
                  CountUpText(
                    value: (progress * 100).round(),
                    format: (n) =>
                        s.creatorDashOverallProgress(n, next.title(s)),
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  QuestProgressBar(
                    value: progress,
                    colors: next.gradient,
                    background: c.surfaceHighest,
                  ),
                ] else
                  Text(
                    s.creatorDashInviteNext,
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
