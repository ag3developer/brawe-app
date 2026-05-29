import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../utils/creator_l10n.dart';
import '../view_models/creator_network_view_model.dart';
import '../widgets/creator_state_views.dart';
import '../widgets/creator_tier_badge.dart';

class CreatorBadgeScreen extends ConsumerWidget {
  const CreatorBadgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final async = ref.watch(myCreatorProfileProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: Text(s.creatorBadgeScreenTitle),
      ),
      body: async.when(
        loading: () => const CreatorLoadingView(),
        error: (e, _) => CreatorErrorView(message: '$e'),
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
          final tier = profile.tier;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: tier.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: tier.color.withValues(alpha: 0.5),
                            blurRadius: 50,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(tier.icon, size: 84, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      tier.title(s),
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CreatorTierBadge(
                      tier: tier,
                      size: 24,
                      showLabel: true,
                      label: s.creatorBadgeUnlocked.toUpperCase(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tier.body(s),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(s.creatorBadgeViewBenefits,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  )),
              const SizedBox(height: 8),
              ...profile.badges.map(
                (b) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified_rounded,
                          color: context.colors.accentPrimary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(b.badgeType,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                      if (b.active)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: context.colors.success
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(s.creatorBadgeActive,
                              style: TextStyle(
                                color: context.colors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              )),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(s.creatorBadgeBack),
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
