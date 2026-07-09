import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../utils/creator_l10n.dart';
import '../view_models/creator_analytics_view_model.dart';
import '../view_models/creator_network_view_model.dart';
import '../widgets/creator_hero_card.dart';
import '../widgets/creator_state_views.dart';
import '../widgets/creator_tier_badge.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CREATOR DASHBOARD SCREEN
// Dados reais via:
//   GET /analytics/dashboard      → KPIs gerais
//   GET /social/stats/:userId     → total_followers
//   GET /analytics/live-history   → histórico de lives
// ─────────────────────────────────────────────────────────────────────────────

class CreatorDashboardScreen extends ConsumerWidget {
  const CreatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final async = ref.watch(myCreatorProfileProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: context.colors.background.withValues(alpha: 0.9),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: const SizedBox.expand(),
          ),
        ),
        title: Text(
          s.creatorDashboardTitle,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.settings,
              size: 20,
              color: context.colors.textSecondary,
            ),
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
            color: AppColors.electricPurple,
            onRefresh: () async {
              ref.invalidate(myCreatorProfileProvider);
              ref.invalidate(creatorDashboardKpisProvider);
              ref.invalidate(creatorSocialStatsProvider);
              await Future.wait([
                ref.read(myCreatorProfileProvider.future),
                ref.read(creatorDashboardKpisProvider.future),
              ]);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight + 12,
                left: 16,
                right: 16,
                bottom: 32,
              ),
              children: [
                // Hero card com tier
                CreatorHeroCard(
                  title: profile.tier.title(s),
                  subtitle: s.creatorDashboardSubtitle,
                  icon: profile.tier.icon,
                  gradient: profile.tier.gradient,
                  actionLabel: s.creatorBadgeViewBenefits,
                  onAction: () => context.push('/creator/badge'),
                ),
                const SizedBox(height: 16),

                // Cards de analytics — dados reais
                _AnalyticsGrid(profile: null),

                const SizedBox(height: 18),

                // Atalhos rápidos
                Text(
                  s.creatorQuickShortcuts,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                _QuickAction(
                  icon: LucideIcons.edit3,
                  label: s.creatorDashboardQuickCreatePost,
                  onTap: () => context.push('/feed'),
                ),
                _QuickAction(
                  icon: LucideIcons.radio,
                  label: s.creatorDashboardQuickGoLive,
                  onTap: () => context.push('/live/start'),
                ),
                _QuickAction(
                  icon: LucideIcons.user,
                  label: s.creatorDashboardQuickEditProfile,
                  onTap: () => context.push('/creator/profile-settings'),
                ),
                _QuickAction(
                  icon: LucideIcons.award,
                  label: s.creatorDashboardQuickViewBadge,
                  onTap: () => context.push('/creator/badge'),
                ),
                const SizedBox(height: 20),
                Center(
                  child: CreatorTierBadge(
                    tier: profile.tier,
                    size: 22,
                    showLabel: true,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Grid de 4 cards de analytics ─────────────────────────────────────────────

class _AnalyticsGrid extends ConsumerWidget {
  final dynamic profile; // não usado diretamente, mantido para extensão

  const _AnalyticsGrid({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final kpisAsync = ref.watch(creatorDashboardKpisProvider);
    final socialAsync = ref.watch(creatorSocialStatsProvider);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _AnalyticsCard(
                icon: LucideIcons.eye,
                color: const Color(0xFF3B82F6),
                label: s.creatorDashboardCardViews,
                valueAsync: kpisAsync.when(
                  data: (k) => _formatCount(k.totalViewers),
                  loading: () => null,
                  error: (_, __) => '—',
                ),
                subtitle: kpisAsync.maybeWhen(
                  data: (k) =>
                      '${_formatCount(k.avgViewersPerLive.toInt())} '
                      'méd./live',
                  orElse: () => null,
                ),
                onTap: () => context.push('/creator/analytics/viewers'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AnalyticsCard(
                icon: LucideIcons.users,
                color: const Color(0xFF8B5CF6),
                label: s.creatorDashboardCardFollowers,
                valueAsync: socialAsync.when(
                  data: (d) => _formatCount(
                    (d['followers_count'] as num?)?.toInt() ?? 0,
                  ),
                  loading: () => null,
                  error: (_, __) => '—',
                ),
                subtitle: 'Ver crescimento',
                onTap: () => context.push('/creator/analytics/followers'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _AnalyticsCard(
                icon: LucideIcons.share2,
                color: const Color(0xFF10B981),
                label: s.creatorDashboardCardReach,
                valueAsync: kpisAsync.when(
                  data: (k) => _formatCount(k.totalProductsSold),
                  loading: () => null,
                  error: (_, __) => '—',
                ),
                subtitle:
                    '${kpisAsync.maybeWhen(data: (k) => k.totalGiftsReceived, orElse: () => 0)} gifts',
                onTap: () => context.push('/creator/analytics/reach'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AnalyticsCard(
                icon: LucideIcons.radio,
                color: const Color(0xFFEC4899),
                label: s.creatorDashboardCardLives,
                valueAsync: kpisAsync.when(
                  data: (k) => _formatCount(k.totalLives),
                  loading: () => null,
                  error: (_, __) => '—',
                ),
                subtitle: kpisAsync.maybeWhen(
                  data: (k) =>
                      '${k.avgDurationMinutes.toStringAsFixed(0)} min méd.',
                  orElse: () => null,
                ),
                onTap: () => context.push('/creator/analytics/lives'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

// ── Card de analytics compacto ────────────────────────────────────────────────

class _AnalyticsCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? valueAsync; // null = loading skeleton
  final String? subtitle;
  final VoidCallback? onTap;

  const _AnalyticsCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.valueAsync,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = valueAsync == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                if (onTap != null)
                  Icon(
                    LucideIcons.chevronRight,
                    size: 14,
                    color: context.colors.textTertiary,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Valor com skeleton de loading
            if (isLoading)
              Container(
                width: 56,
                height: 22,
                decoration: BoxDecoration(
                  color: context.colors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            else
              Text(
                valueAsync!,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 11,
                height: 1.3,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Quick action tile ─────────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              Icon(icon, color: AppColors.electricPurple, size: 18),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: context.colors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
