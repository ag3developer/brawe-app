import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../domain/models/quest.dart';
import '../../../domain/models/user.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../view_models/quests_view_model.dart';

/// Tela gamificada de missões diárias.
///
/// - Fundo escuro com gradiente dinâmico (estilo Duolingo/Habitica).
/// - Cores vibrantes por categoria.
/// - Animação de progresso, confete ao reclamar, shimmer no botão.
/// - Pull-to-refresh.
class QuestsScreen extends ConsumerWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final async = ref.watch(questsViewModelProvider);
    final authState = ref.watch(authStateProvider);
    final currentUser =
        authState is AsyncData<User?> ? authState.value : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0824),
      body: Stack(
        children: [
          // Background gradient + decorative blobs
          const _AnimatedBackground(),
          SafeArea(
            child: async.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (e, _) => _ErrorView(
                onRetry: () =>
                    ref.read(questsViewModelProvider.notifier).refresh(),
              ),
              data: (data) => RefreshIndicator(
                color: AppColors.electricPurple,
                onRefresh: () =>
                    ref.read(questsViewModelProvider.notifier).refresh(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _Header(title: s.questsTitle),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _HeroCard(
                            profile: data.profile,
                            streak: data.streak,
                            avatarUrl: currentUser?.avatarUrl,
                          ),
                          const SizedBox(height: 16),
                          _SummaryRow(
                            summary: data.summary,
                            streak: data.streak,
                          ),
                          if (_mascotFor(data) != null) ...[
                            const SizedBox(height: 16),
                            _MascotBanner(
                              asset: _mascotFor(data)!.asset,
                              message: _mascotFor(data)!.message(context),
                              tint: _mascotFor(data)!.tint,
                            ),
                          ],
                          const SizedBox(height: 20),
                          if (_claimableCount(data) >= 2)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _ClaimAllButton(
                                count: _claimableCount(data),
                                onTap: () => _onClaimAll(context, ref),
                              ),
                            ),
                          _SectionTitle(title: s.questsTitle),
                          const SizedBox(height: 10),
                          if (data.quests.isEmpty)
                            _EmptyState(text: s.questsEmpty)
                          else
                            ...data.quests.map(
                              (q) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _QuestCard(
                                  quest: q,
                                  onClaim: () => _onClaimOne(context, ref, q),
                                ),
                              ),
                            ),
                        ]),
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

  int _claimableCount(QuestsData d) =>
      d.quests.where((q) => q.isClaimable).length;

  /// Decide qual mascote (se algum) exibir no banner condicional do topo.
  /// - Tudo concluído → mascote comemorando.
  /// - Streak >= 3 → mascote em chamas.
  /// - Senão → null (sem banner).
  _MascotState? _mascotFor(QuestsData d) {
    final allDone = d.quests.isNotEmpty &&
        d.quests.every((q) => q.isClaimed);
    if (allDone) {
      return _MascotState(
        asset: 'mascot_celebrate.png',
        tint: const Color(0xFFFFD93D),
        message: (ctx) => '🎉 Você completou todas as missões de hoje!',
      );
    }
    if (d.streak.current >= 3) {
      return _MascotState(
        asset: 'mascot_fire.png',
        tint: const Color(0xFFFF5E5E),
        message: (ctx) =>
            '🔥 Sequência de ${d.streak.current} dias! Continue assim!',
      );
    }
    return null;
  }

  Future<void> _onClaimAll(BuildContext context, WidgetRef ref) async {
    final s = S.of(context);
    final n = await ref.read(questsViewModelProvider.notifier).claimAll();
    if (!context.mounted) return;
    _showRewardSnack(
      context,
      n > 0 ? s.questsClaimedReward(n) : s.questsNothingToClaim,
    );
  }

  Future<void> _onClaimOne(
    BuildContext context,
    WidgetRef ref,
    DailyQuest q,
  ) async {
    final s = S.of(context);
    try {
      await ref.read(questsViewModelProvider.notifier).claimQuest(q.questKey);
      if (!context.mounted) return;
      _showRewardSnack(
        context,
        s.questsClaimSuccess(q.xpReward, q.coinsReward),
      );
    } catch (_) {
      if (!context.mounted) return;
      _showRewardSnack(context, s.questsClaimError, error: true);
    }
  }

  void _showRewardSnack(
    BuildContext context,
    String text, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error
            ? Colors.redAccent.shade400
            : AppColors.electricPurple,
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline : Icons.celebration,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// HEADER
// ════════════════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.maybePop(context),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// BACKGROUND
// ════════════════════════════════════════════════════════════════════════

class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A0E3D),
            Color(0xFF0F0824),
            Color(0xFF0A0518),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SizedBox.expand(
        child: _BlobsOverlay(),
      ),
    );
  }
}

class _BlobsOverlay extends StatelessWidget {
  const _BlobsOverlay();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -60,
          child: _glow(220, AppColors.electricPurple.withValues(alpha: 0.55)),
        ),
        Positioned(
          top: 200,
          left: -80,
          child: _glow(260, AppColors.coolCyan.withValues(alpha: 0.35)),
        ),
        Positioned(
          bottom: -100,
          right: -40,
          child: _glow(280, const Color(0xFFFF4D8D).withValues(alpha: 0.30)),
        ),
      ],
    );
  }

  Widget _glow(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════
// HERO CARD — Nivel + XP + Streak
// ════════════════════════════════════════════════════════════════════════

class _HeroCard extends StatelessWidget {
  final QuestProfile profile;
  final QuestStreak streak;
  final String? avatarUrl;
  const _HeroCard({
    required this.profile,
    required this.streak,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6E4DFF),
            Color(0xFF8A5BFF),
            Color(0xFF3BB8FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricPurple.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Decorative background overlay (silently absent if asset missing).
            Positioned.fill(
              child: Opacity(
                opacity: 0.35,
                child: Image.asset(
                  'assets/images/quests/hero_bg.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, e, s) => const SizedBox.shrink(),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Row(
            children: [
              _LevelBadge(level: profile.level, avatarUrl: avatarUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).questsLevel(profile.level),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      S.of(context).questsXpProgress(
                        profile.xpIntoLevel,
                        profile.xpToNextLevel,
                      ),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (streak.multiplierLabel != null)
                _MultiplierPill(label: streak.multiplierLabel!),
              const SizedBox(width: 6),
              const _QuestImage(
                assetName: 'trophy.png',
                fallbackIcon: Icons.emoji_events,
                size: 44,
                fallbackColor: Color(0xFFFFD93D),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _AnimatedProgressBar(
            value: profile.levelProgressPercent / 100,
            background: Colors.white.withValues(alpha: 0.22),
            color: Colors.white,
            height: 10,
          ),
        ],
      ),
          ],
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  final String? avatarUrl;
  const _LevelBadge({required this.level, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final tier = _LevelTier.fromLevel(level);
    const size = 72.0;
    const avatarSize = 52.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 1) Glow colorido por trás (depende do tier)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: tier.glow.withValues(alpha: 0.55),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          // 2) Avatar circular (foto do user) — com fallback pra inicial.
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: tier.ringColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(2.5),
            child: ClipOval(
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, e, st) => _avatarFallback(),
                    )
                  : _avatarFallback(),
            ),
          ),
          // 3) Moldura PNG sobreposta (silenciosamente some se não existir).
          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/quests/${tier.frameAsset}',
                fit: BoxFit.contain,
                errorBuilder: (_, e, st) => const SizedBox.shrink(),
              ),
            ),
          ),
          // 4) Selo de level no canto inferior direito (gradient).
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: tier.badgeColors),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: tier.glow.withValues(alpha: 0.55),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '$level',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 2,
                      offset: Offset(0, 1),
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

  Widget _avatarFallback() {
    return Container(
      color: const Color(0xFF2A1854),
      alignment: Alignment.center,
      child: const Icon(Icons.person, color: Colors.white70, size: 28),
    );
  }
}

/// Tier de moldura/aro do avatar baseado no level.
///
/// 5 patamares — quanto maior o level, mais raro/épico o visual.
/// PNGs em `assets/images/quests/frame_<tier>.png`. Se não existirem,
/// o aro gradient + selo de level continuam funcionando como fallback.
class _LevelTier {
  final String name;
  final String frameAsset;
  final List<Color> ringColors;
  final List<Color> badgeColors;
  final Color glow;

  const _LevelTier({
    required this.name,
    required this.frameAsset,
    required this.ringColors,
    required this.badgeColors,
    required this.glow,
  });

  static _LevelTier fromLevel(int level) {
    if (level >= 50) return _legendary;
    if (level >= 25) return _epic;
    if (level >= 10) return _gold;
    if (level >= 5) return _silver;
    return _bronze;
  }

  // Bronze — level 1-4 (iniciante)
  static const _bronze = _LevelTier(
    name: 'bronze',
    frameAsset: 'frame_bronze.png',
    ringColors: [Color(0xFFCD7F32), Color(0xFF8B5A2B)],
    badgeColors: [Color(0xFFCD7F32), Color(0xFF8B5A2B)],
    glow: Color(0xFFCD7F32),
  );
  // Silver — level 5-9
  static const _silver = _LevelTier(
    name: 'silver',
    frameAsset: 'frame_silver.png',
    ringColors: [Color(0xFFE0E0E0), Color(0xFF9E9E9E)],
    badgeColors: [Color(0xFFBDBDBD), Color(0xFF757575)],
    glow: Color(0xFFE0E0E0),
  );
  // Gold — level 10-24
  static const _gold = _LevelTier(
    name: 'gold',
    frameAsset: 'frame_gold.png',
    ringColors: [Color(0xFFFFD93D), Color(0xFFFF8B33)],
    badgeColors: [Color(0xFFFFD93D), Color(0xFFFF8B33)],
    glow: Color(0xFFFFD93D),
  );
  // Epic — level 25-49 (roxo/rosa neon)
  static const _epic = _LevelTier(
    name: 'epic',
    frameAsset: 'frame_epic.png',
    ringColors: [Color(0xFFB14DFF), Color(0xFFFF4D8D)],
    badgeColors: [Color(0xFF8A5BFF), Color(0xFFFF4D8D)],
    glow: Color(0xFFB14DFF),
  );
  // Legendary — level 50+ (chamas/dourado lendário)
  static const _legendary = _LevelTier(
    name: 'legendary',
    frameAsset: 'frame_legendary.png',
    ringColors: [Color(0xFFFFD93D), Color(0xFFFF4D8D), Color(0xFF3BB8FF)],
    badgeColors: [Color(0xFFFFD93D), Color(0xFFFF4D8D)],
    glow: Color(0xFFFFD93D),
  );
}

class _MultiplierPill extends StatelessWidget {
  final String label;
  const _MultiplierPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flash_on, color: Color(0xFFFFD93D), size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// SUMMARY CARDS (Completed | XP today | Streak)
// ════════════════════════════════════════════════════════════════════════

class _SummaryRow extends StatelessWidget {
  final QuestSummary summary;
  final QuestStreak streak;
  const _SummaryRow({required this.summary, required this.streak});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: s.questsSummaryCompleted,
            value: s.questsSummaryCompletedValue(
              summary.completed,
              summary.totalQuests,
            ),
            icon: Icons.check_circle,
            tint: const Color(0xFF2BD995),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: s.questsSummaryXpToday,
            value: '${summary.totalXpToday}',
            icon: Icons.bolt,
            tint: const Color(0xFFFFD93D),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: s.questsSummaryStreak,
            value: s.questsStreakDays(streak.current),
            icon: Icons.local_fire_department,
            tint: const Color(0xFFFF5E5E),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: tint),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// SECTION TITLE
// ════════════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.electricPurple, AppColors.coolCyan],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// CLAIM ALL BUTTON
// ════════════════════════════════════════════════════════════════════════

class _ClaimAllButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _ClaimAllButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD93D), Color(0xFFFF8B33), Color(0xFFFF4D8D)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8B33).withValues(alpha: 0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _QuestImage(
                    assetName: 'reward_chest.png',
                    fallbackIcon: Icons.celebration,
                    size: 36,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    S.of(context).questsClaimAll(count),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// QUEST CARD (gamificado, por categoria)
// ════════════════════════════════════════════════════════════════════════

class _QuestCard extends StatelessWidget {
  final DailyQuest quest;
  final VoidCallback onClaim;
  const _QuestCard({required this.quest, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    final claimed = quest.isClaimed;
    final claimable = quest.isClaimable;
    final palette = _paletteFor(quest);
    final icon = _iconFor(quest.icon);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: claimed
              ? [
                  Colors.white.withValues(alpha: 0.04),
                  Colors.white.withValues(alpha: 0.02),
                ]
              : [
                  palette.start.withValues(alpha: 0.18),
                  palette.end.withValues(alpha: 0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: claimable
              ? palette.end
              : Colors.white.withValues(alpha: 0.08),
          width: claimable ? 2 : 1,
        ),
        boxShadow: claimable
            ? [
                BoxShadow(
                  color: palette.end.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : const [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [palette.start, palette.end],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: palette.end.withValues(alpha: claimed ? 0.15 : 0.55),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _QuestImage(
                    assetName: _assetNameFor(quest),
                    fallbackIcon: icon,
                    size: 52,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Colors.white.withValues(
                          alpha: claimed ? 0.55 : 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      quest.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              _RewardChip(
                xp: quest.xpReward,
                coins: quest.coinsReward,
                tint: palette.end,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _AnimatedProgressBar(
            value: quest.progressPercent / 100,
            background: Colors.white.withValues(alpha: 0.08),
            color: claimed
                ? const Color(0xFF2BD995)
                : (claimable ? palette.end : palette.start),
            height: 8,
            gradient: claimed
                ? null
                : [palette.start, palette.end],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).questsProgressCount(
                  quest.currentCount,
                  quest.targetCount,
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (claimed)
                _StatusPill(
                  text: S.of(context).questsStatusClaimed,
                  color: const Color(0xFF2BD995),
                  icon: Icons.check_circle,
                )
              else if (claimable)
                _ClaimButton(onTap: onClaim, color: palette.end)
              else
                _StatusPill(
                  text: S.of(context).questsStatusInProgress,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestPalette {
  final Color start;
  final Color end;
  const _QuestPalette(this.start, this.end);
}

_QuestPalette _paletteFor(DailyQuest q) {
  switch (q.category) {
    case 'engagement':
      return const _QuestPalette(Color(0xFF6E4DFF), Color(0xFF3BB8FF));
    case 'social':
      return const _QuestPalette(Color(0xFFFF4D8D), Color(0xFFFFD93D));
    case 'creator':
      return const _QuestPalette(Color(0xFF2BD995), Color(0xFF3BB8FF));
    default:
      return const _QuestPalette(Color(0xFF6E4DFF), Color(0xFFFF4D8D));
  }
}

IconData _iconFor(String key) {
  switch (key) {
    case 'Play':
      return Icons.play_circle;
    case 'Heart':
      return Icons.favorite;
    case 'MessageCircle':
      return Icons.chat_bubble;
    case 'UserPlus':
      return Icons.person_add;
    case 'Share2':
      return Icons.share;
    case 'Camera':
      return Icons.camera_alt;
    default:
      return Icons.stars;
  }
}

/// Mapeia a categoria/ícone da quest para um nome de asset PNG.
/// Se o asset não existir em `assets/images/quests/`, o widget [_QuestImage]
/// faz fallback automaticamente para o [IconData] correspondente.
String _assetNameFor(DailyQuest q) {
  // Primeiro tenta por ícone (mais específico vindo do backend).
  switch (q.icon) {
    case 'Heart':
      return 'icon_like.png';
    case 'MessageCircle':
      return 'icon_comment.png';
    case 'UserPlus':
      return 'icon_follow.png';
    case 'Camera':
      return 'icon_post.png';
    case 'Share2':
      return 'icon_share.png';
    case 'Play':
      return 'icon_watch.png';
  }
  // Fallback por categoria.
  switch (q.category) {
    case 'engagement':
      return 'icon_like.png';
    case 'social':
      return 'icon_follow.png';
    case 'creator':
      return 'icon_post.png';
    default:
      return 'icon_streak.png';
  }
}

/// Widget que tenta carregar uma imagem de `assets/images/quests/` e,
/// se o arquivo não existir, mostra um [IconData] como fallback.
///
/// Permite que o time de design adicione/troque PNGs sem mexer no código.
class _QuestImage extends StatelessWidget {
  final String assetName;
  final IconData fallbackIcon;
  final double size;
  final Color fallbackColor;
  const _QuestImage({
    required this.assetName,
    required this.fallbackIcon,
    required this.size,
    this.fallbackColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    // Mapeia para ilustrações 3D oficiais quando disponíveis
    final mapped = _mapToBraweIllustration(assetName);
    if (mapped != null) {
      return Image.asset(
        mapped,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, e, s) =>
            Icon(fallbackIcon, color: fallbackColor, size: size * 0.75),
      );
    }
    return Image.asset(
      'assets/images/quests/$assetName',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, e, s) =>
          Icon(fallbackIcon, color: fallbackColor, size: size * 0.75),
    );
  }

  static String? _mapToBraweIllustration(String name) {
    switch (name) {
      case 'trophy.png':
        return 'assets/images/illustrations/trophy_3d.png';
      case 'coin_brc.png':
        return 'assets/images/illustrations/coin_3d.png';
      case 'reward_chest.png':
        return 'assets/images/illustrations/package_3d.png';
      case 'empty_state.png':
        return 'assets/images/illustrations/master_3d.png';
      default:
        return null;
    }
  }
}

// ════════════════════════════════════════════════════════════════════════
// REWARD CHIP / CLAIM BUTTON / STATUS PILL
// ════════════════════════════════════════════════════════════════════════

class _RewardChip extends StatelessWidget {
  final int xp;
  final int coins;
  final Color tint;
  const _RewardChip({
    required this.xp,
    required this.coins,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tint.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              const _QuestImage(
                assetName: 'xp_bolt.png',
                fallbackIcon: Icons.bolt,
                size: 14,
                fallbackColor: Color(0xFFFFD93D),
              ),
              const SizedBox(width: 2),
              Text(
                '+$xp',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const _QuestImage(
                assetName: 'coin_brc.png',
                fallbackIcon: Icons.monetization_on,
                size: 13,
                fallbackColor: Color(0xFFFFB84D),
              ),
              const SizedBox(width: 2),
              Text(
                '+$coins',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClaimButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color color;
  const _ClaimButton({required this.onTap, required this.color});

  @override
  State<_ClaimButton> createState() => _ClaimButtonState();
}

class _ClaimButtonState extends State<_ClaimButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final scale = 1.0 + 0.04 * math.sin(_ctrl.value * math.pi * 2);
        return Transform.scale(
          scale: scale,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.55),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    S.of(context).questsActionClaim,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const _StatusPill({required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// ANIMATED PROGRESS BAR
// ════════════════════════════════════════════════════════════════════════

class _AnimatedProgressBar extends StatelessWidget {
  final double value;
  final Color background;
  final Color color;
  final List<Color>? gradient;
  final double height;
  const _AnimatedProgressBar({
    required this.value,
    required this.background,
    required this.color,
    required this.height,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(height: height, color: background),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0, 1)),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => FractionallySizedBox(
              widthFactor: v,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  gradient: gradient != null
                      ? LinearGradient(colors: gradient!)
                      : null,
                  color: gradient == null ? color : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// EMPTY + ERROR
// ════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            const _QuestImage(
              assetName: 'empty_state.png',
              fallbackIcon: Icons.emoji_events,
              size: 120,
              fallbackColor: Color(0xFFFFD93D),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 40, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            s.questsLoadError,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.electricPurple,
            ),
            child: Text(s.questsTryAgain),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// MASCOT BANNER (aparece condicionalmente: streak alto ou tudo concluído)
// ════════════════════════════════════════════════════════════════════════

class _MascotState {
  final String asset;
  final Color tint;
  final String Function(BuildContext) message;
  const _MascotState({
    required this.asset,
    required this.tint,
    required this.message,
  });
}

class _MascotBanner extends StatelessWidget {
  final String asset;
  final String message;
  final Color tint;
  const _MascotBanner({
    required this.asset,
    required this.message,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 18, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tint.withValues(alpha: 0.22),
            tint.withValues(alpha: 0.06),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tint.withValues(alpha: 0.45), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: tint.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _QuestImage(
            assetName: asset,
            fallbackIcon: Icons.emoji_emotions,
            size: 64,
            fallbackColor: tint,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
