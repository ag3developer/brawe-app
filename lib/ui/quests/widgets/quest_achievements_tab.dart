import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'quest_tones.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/services/feedback_service.dart';
import '../../../domain/models/quest_journey.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/ui/image_decode.dart';
import '../../live/shared/widgets/award_badge.dart' show awardColor;
import '../../settings/view_models/settings_view_model.dart';
import '../view_models/quests_view_model.dart';
import 'quest_visuals.dart';

/// Aba "Conquistas": números da vida toda, emblemas e prêmios recebidos.
class QuestAchievementsTab extends ConsumerStatefulWidget {
  const QuestAchievementsTab({super.key});

  @override
  ConsumerState<QuestAchievementsTab> createState() =>
      _QuestAchievementsTabState();
}

class _QuestAchievementsTabState extends ConsumerState<QuestAchievementsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final async = ref.watch(questJourneyProvider);
    return async.when(
      loading: () => const _JourneyLoading(),
      error: (_, _) => QuestJourneyError(
        onRetry: () => ref.read(questJourneyProvider.notifier).refresh(),
      ),
      data: (j) => RefreshIndicator(
        color: context.colors.accentPrimary,
        onRefresh: () => ref.read(questJourneyProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          children: [
            StaggerIn(index: 0, child: _StatsGrid(stats: j.stats)),
            const SizedBox(height: 24),
            StaggerIn(
              index: 1,
              child: _Header(
                title: S.of(context).questsBadgesTitle,
                trailing: S
                    .of(context)
                    .questsBadgesCount(
                      j.stats.badgesUnlocked,
                      j.stats.badgesTotal,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            StaggerIn(
              index: 2,
              child: _BadgeShelf(
                badges: j.badges,
                currentStreak: j.stats.currentStreak,
                onTap: (b) => _openBadge(b, j.stats.currentStreak),
              ),
            ),
            const SizedBox(height: 26),
            StaggerIn(
              index: 3,
              child: _Header(
                title: S.of(context).questsAwardsTitle,
                trailing: j.awards.isEmpty ? null : '${j.awards.length}',
              ),
            ),
            const SizedBox(height: 12),
            if (j.awards.isEmpty)
              StaggerIn(index: 4, child: const _AwardsEmpty())
            else
              for (var i = 0; i < j.awards.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: StaggerIn(
                    index: 4 + i,
                    child: QuestAwardTile(award: j.awards[i]),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  void _openBadge(JourneyBadge b, int streak) {
    final fb = ref.read(feedbackServiceProvider);
    fb.setSoundsEnabled(
      ref.read(settingsViewModelProvider).value?.soundsEnabled ?? true,
    );
    b.unlocked ? fb.questBadge() : fb.questTap();
    showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      backgroundColor: context.colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _BadgeSheet(badge: b, streak: streak),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Números
// ════════════════════════════════════════════════════════════════════════

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});
  final JourneyStats stats;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final items = [
      (
        s.questsStatQuests,
        stats.totalQuestsCompleted,
        'assets/images/quests/stat_trophy.png',
        QuestTones.violet,
      ),
      (
        s.questsStatXp,
        stats.totalXpEarned,
        'assets/images/quests/stat_xp.png',
        QuestTones.cyan,
      ),
      (
        s.questsStatCoins,
        stats.totalCoinsEarned,
        'assets/images/quests/stat_coin.png',
        QuestTones.gold,
      ),
      (
        s.questsStatBestStreak,
        stats.longestStreak,
        'assets/images/quests/stat_streak.png',
        QuestTones.ember,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(title: s.questsStatsTitle),
        const SizedBox(height: 12),
        // Carrossel: ocupa uma faixa só e a imagem ganha destaque.
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(
              width: 178,
              child: GameTile(
                tint: items[i].$4,
                radius: 22,
                padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
                child: Row(
                  children: [
                    Floating(
                      phase: i * 0.25,
                      amplitude: 3,
                      child: Image.asset(
                        items[i].$3,
                        width: 62,
                        height: 62,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const SizedBox(width: 62),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: CountUpText(
                              value: items[i].$2,
                              style: TextStyle(
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Text(
                            items[i].$1,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
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
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, this.trailing});
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.accentPrimary, colors.accentSecondary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Emblemas
// ════════════════════════════════════════════════════════════════════════

class _BadgeShelf extends StatelessWidget {
  const _BadgeShelf({
    required this.badges,
    required this.currentStreak,
    required this.onTap,
  });

  final List<JourneyBadge> badges;
  final int currentStreak;
  final ValueChanged<JourneyBadge> onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return GameTile(
      tint: colors.accentPrimary,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: badges.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (_, i) {
          final b = badges[i];
          final progress = b.threshold == 0
              ? 0.0
              : (currentStreak / b.threshold).clamp(0.0, 1.0);
          return GestureDetector(
            onTap: () => onTap(b),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Floating(
                  enabled: b.unlocked,
                  phase: i / 6,
                  amplitude: 3,
                  child: QuestBadgeMedal(
                    badgeKey: b.key,
                    unlocked: b.unlocked,
                    size: 66,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  questBadgeName(s, b.key),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: b.unlocked
                        ? colors.textPrimary
                        : colors.textTertiary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                if (b.unlocked)
                  Text(
                    s.questsBadgeEarned,
                    style: TextStyle(
                      color: colors.success,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: QuestProgressBar(
                      value: progress,
                      colors: questBadgeColors(b.key),
                      background: colors.surfaceHighest,
                      height: 5,
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

class _BadgeSheet extends StatelessWidget {
  const _BadgeSheet({required this.badge, required this.streak});
  final JourneyBadge badge;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Sparkles(
              enabled: badge.unlocked,
              count: 8,
              child: Floating(
                enabled: badge.unlocked,
                child: QuestBadgeMedal(
                  badgeKey: badge.key,
                  unlocked: badge.unlocked,
                  size: 120,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              questBadgeName(s, badge.key),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              s.questsBadgeRequirement(badge.threshold),
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (badge.unlocked)
              _Pill(
                icon: LucideIcons.badgeCheck,
                color: colors.success,
                text: badge.earnedAt != null
                    ? s.questsBadgeEarnedOn(
                        DateFormat.yMMMd(locale).format(badge.earnedAt!),
                      )
                    : s.questsBadgeEarned,
              )
            else ...[
              QuestProgressBar(
                value: badge.threshold == 0
                    ? 0
                    : (streak / badge.threshold).clamp(0.0, 1.0),
                colors: questBadgeColors(badge.key),
                background: colors.surfaceHighest,
                height: 10,
              ),
              const SizedBox(height: 8),
              Text(
                s.questsBadgeProgress(
                  streak.clamp(0, badge.threshold),
                  badge.threshold,
                ),
                style: TextStyle(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Prêmios
// ════════════════════════════════════════════════════════════════════════

/// Cartão de um prêmio recebido (também usado na linha do tempo).
class QuestAwardTile extends StatelessWidget {
  const QuestAwardTile({super.key, required this.award, this.compact = false});

  final JourneyAward award;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final lang = Localizations.localeOf(context).languageCode;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final color = awardColor(award.award.badgeColor);
    final active = award.isActive;
    final dateFmt = DateFormat.yMMMd(locale);

    final (statusText, statusColor) = switch (award.status) {
      'active' => (s.questsAwardActive, colors.success),
      'expired' => (s.questsAwardExpired, colors.textTertiary),
      'revoked' => (s.questsAwardRevoked, colors.danger),
      _ => (s.questsAwardScheduled, colors.warning),
    };
    final source = switch (award.award.sourceKind) {
      'event' => s.questsAwardSourceEvent,
      'creator_week' => s.questsAwardSourceCreatorWeek,
      'live' => s.questsAwardSourceLive,
      'battle' => s.questsAwardSourceBattle,
      _ => null,
    };
    final String? when;
    if (award.status == 'scheduled' && award.startsAt != null) {
      when = s.questsAwardStartsOn(dateFmt.format(award.startsAt!));
    } else if (active && award.award.expiresAt != null) {
      when = s.questsAwardValidUntil(dateFmt.format(award.award.expiresAt!));
    } else if (award.status == 'revoked' && award.revokedAt != null) {
      when = s.questsAwardEndedOn(dateFmt.format(award.revokedAt!));
    } else if (award.award.expiresAt != null) {
      when = s.questsAwardEndedOn(dateFmt.format(award.award.expiresAt!));
    } else {
      when = null;
    }

    final image = Container(
      width: compact ? 46 : 62,
      height: compact ? 46 : 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, QuestTones.shade, 0.25)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: active
            ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 14)]
            : null,
        border: Border.all(
          color: QuestTones.onGradient.withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(3),
      child: ClipOval(
        child: award.award.badgeImageUrl == null
            ? const Icon(LucideIcons.award, color: QuestTones.onGradient)
            : CachedNetworkImage(
                imageUrl: award.award.badgeImageUrl!,
                fit: BoxFit.cover,
                memCacheWidth: context.decodePx(compact ? 46 : 62),
                errorWidget: (_, _, _) =>
                    const Icon(LucideIcons.award, color: QuestTones.onGradient),
              ),
      ),
    );

    final body = Row(
      children: [
        Opacity(
          opacity: active || award.status == 'scheduled' ? 1 : 0.5,
          child: Floating(enabled: active, amplitude: 3, child: image),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                award.award.localizedLabel(lang),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 14 : 15,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _Pill(text: statusText, color: statusColor, small: true),
                  if (source != null)
                    _Pill(text: source, color: color, small: true),
                  if (award.rank != null && award.rank! > 0)
                    _Pill(
                      text: s.questsAwardRank(award.rank!),
                      color: QuestTones.gold,
                      small: true,
                      icon: LucideIcons.trophy,
                    ),
                  if (!compact && award.freeCoins > 0)
                    _Pill(
                      text: s.questsAwardCoins(award.freeCoins),
                      color: QuestTones.gold,
                      small: true,
                      icon: LucideIcons.coins,
                    ),
                  if (!compact && award.award.frameUrl != null)
                    _Pill(
                      text: s.questsAwardFrame,
                      color: colors.accentPrimary,
                      small: true,
                      icon: LucideIcons.frame,
                    ),
                  if (!compact && award.hasEntry)
                    _Pill(
                      text: s.questsAwardEntry,
                      color: colors.accentPink,
                      small: true,
                      icon: LucideIcons.sparkles,
                    ),
                ],
              ),
              if (when != null && !compact) ...[
                const SizedBox(height: 6),
                Text(
                  when,
                  style: TextStyle(color: colors.textTertiary, fontSize: 11.5),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    if (compact) return body;
    return GameTile(tint: active ? color : colors.textTertiary, child: body);
  }
}

class _AwardsEmpty extends StatelessWidget {
  const _AwardsEmpty();

  @override
  Widget build(BuildContext context) {
    return GameTile(
      tint: context.colors.accentGold,
      child: Row(
        children: [
          Floating(
            child: Image.asset(
              'assets/images/quests/stat_gift.png',
              width: 64,
              height: 64,
              errorBuilder: (_, _, _) => const SizedBox(width: 64),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              S.of(context).questsAwardsEmpty,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.color,
    this.icon,
    this.small = false,
  });

  final String text;
  final Color color;
  final IconData? icon;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 7 : 12,
        vertical: small ? 2 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: small ? 11 : 15, color: color),
            SizedBox(width: small ? 3 : 5),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: small ? 10.5 : 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Estados de carregamento / erro (compartilhados com a Jornada)
// ════════════════════════════════════════════════════════════════════════

class _JourneyLoading extends StatelessWidget {
  const _JourneyLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Floating(
        child: Image.asset(
          'assets/images/quests/reward_chest.png',
          width: 90,
          errorBuilder: (_, _, _) =>
              CircularProgressIndicator(color: context.colors.accentPrimary),
        ),
      ),
    );
  }
}

class QuestJourneyError extends StatelessWidget {
  const QuestJourneyError({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/quests/empty_state.png',
              height: 130,
              errorBuilder: (_, _, _) => const SizedBox(height: 130),
            ),
            const SizedBox(height: 12),
            Text(
              s.questsJourneyError,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: Text(s.questsTryAgain)),
          ],
        ),
      ),
    );
  }
}

/// Carregando (reaproveitado pela Jornada).
class QuestJourneyLoading extends StatelessWidget {
  const QuestJourneyLoading({super.key});
  @override
  Widget build(BuildContext context) => const _JourneyLoading();
}
