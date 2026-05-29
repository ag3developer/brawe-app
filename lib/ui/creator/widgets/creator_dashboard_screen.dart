import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../utils/creator_l10n.dart';
import '../view_models/creator_network_view_model.dart';
import '../widgets/creator_hero_card.dart';
import '../widgets/creator_state_views.dart';
import '../widgets/creator_tier_badge.dart';

class CreatorDashboardScreen extends ConsumerWidget {
  const CreatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final async = ref.watch(myCreatorProfileProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: Text(s.creatorDashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/creator/profile-settings'),
          ),
        ],
      ),
      body: async.when(
        loading: () => const CreatorLoadingView(),
        error: (e, _) => CreatorErrorView(message: '$e'),
        data: (profile) {
          if (profile == null) {
            return CreatorEmptyState(
              icon: Icons.workspace_premium_outlined,
              title: s.creatorBadgeLocked,
              subtitle: s.creatorProgramDescription,
              actionLabel: s.creatorActionApplyNow,
              onAction: () => context.go('/creator/apply'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myCreatorProfileProvider);
              await ref.read(myCreatorProfileProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                CreatorHeroCard(
                  title: profile.tier.title(s),
                  subtitle: s.creatorDashboardSubtitle,
                  icon: profile.tier.icon,
                  gradient: profile.tier.gradient,
                  actionLabel: s.creatorBadgeViewBenefits,
                  onAction: () => context.push('/creator/badge'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.remove_red_eye_outlined,
                        label: s.creatorDashboardCardViews,
                        value: '—',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.group_add_outlined,
                        label: s.creatorDashboardCardFollowers,
                        value: '—',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.share_outlined,
                        label: s.creatorDashboardCardReach,
                        value: '—',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.podcasts_rounded,
                        label: s.creatorDashboardCardLives,
                        value: '—',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(s.creatorQuickShortcuts,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    )),
                const SizedBox(height: 10),
                _quick(context, Icons.edit_rounded,
                    s.creatorDashboardQuickCreatePost, () => context.push('/feed')),
                _quick(context, Icons.podcasts_rounded,
                    s.creatorDashboardQuickGoLive, () => context.push('/live/start')),
                _quick(context, Icons.person_outline_rounded,
                    s.creatorDashboardQuickEditProfile,
                    () => context.push('/creator/profile-settings')),
                _quick(context, Icons.workspace_premium_rounded,
                    s.creatorDashboardQuickViewBadge,
                    () => context.push('/creator/badge')),
                const SizedBox(height: 20),
                Center(
                  child: CreatorTierBadge(
                      tier: profile.tier, size: 22, showLabel: true),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _quick(BuildContext context, IconData icon, String label,
      VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: context.colors.accentPrimary, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: context.colors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.colors.accentPrimary, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 12,
                height: 1.3,
              )),
        ],
      ),
    );
  }
}
