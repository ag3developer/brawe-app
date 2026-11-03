import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/services/feedback_service.dart';
import '../../../domain/models/quest.dart';
import '../../../domain/models/quest_journey.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../settings/view_models/settings_view_model.dart';
import '../view_models/quests_view_model.dart';
import 'quest_celebration.dart';
import 'quest_hero.dart';
import 'quest_visuals.dart';

/// Aba "Missões": cartão do nível, progresso do dia e as missões.
class QuestMissionsTab extends ConsumerStatefulWidget {
  const QuestMissionsTab({
    super.key,
    required this.data,
    this.avatarUrl,
    this.highlightKey,
  });

  final QuestsData data;
  final String? avatarUrl;

  /// Missão aberta pela notificação: rola até ela e destaca.
  final String? highlightKey;

  @override
  ConsumerState<QuestMissionsTab> createState() => _QuestMissionsTabState();
}

class _QuestMissionsTabState extends ConsumerState<QuestMissionsTab>
    with AutomaticKeepAliveClientMixin {
  final _highlightAnchor = GlobalKey();
  bool _scrolledToHighlight = false;
  bool _claimingAll = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToHighlight());
  }

  void _scrollToHighlight() {
    if (_scrolledToHighlight || widget.highlightKey == null) return;
    final ctx = _highlightAnchor.currentContext;
    if (ctx == null) return;
    _scrolledToHighlight = true;
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted || _highlightAnchor.currentContext == null) return;
      Scrollable.ensureVisible(
        _highlightAnchor.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        alignment: 0.3,
      );
    });
  }

  // ── Resgates ─────────────────────────────────────────────────────────

  Future<void> _claimOne(DailyQuest q, Offset origin) async {
    final s = S.of(context);
    try {
      final result = await ref
          .read(questsViewModelProvider.notifier)
          .claimQuest(q.questKey);
      if (!mounted) return;
      await _celebrate(
        result ??
            QuestClaimResult(
              xp: q.xpReward,
              coins: q.coinsReward,
              levelUp: false,
              newLevel: 0,
              newBadgeKeys: const [],
              streakIncreased: false,
              streak: 0,
            ),
        origin,
      );
    } catch (_) {
      if (!mounted) return;
      _snack(s.questsClaimError, error: true);
    }
  }

  Future<void> _claimAll(Offset origin) async {
    if (_claimingAll) return;
    final s = S.of(context);
    setState(() => _claimingAll = true);
    final result =
        await ref.read(questsViewModelProvider.notifier).claimAll();
    if (!mounted) return;
    setState(() => _claimingAll = false);
    if (result == null) {
      _snack(s.questsNothingToClaim);
      return;
    }
    await _celebrate(result, origin);
  }

  /// Serviço de sons respeitando a opção "Sons" das configurações.
  FeedbackService _sfx() {
    final fb = ref.read(feedbackServiceProvider);
    fb.setSoundsEnabled(
      ref.read(settingsViewModelProvider).value?.soundsEnabled ?? true,
    );
    return fb;
  }

  Future<void> _celebrate(QuestClaimResult r, Offset origin) async {
    _sfx().questClaim();
    showQuestRewardBurst(context, origin: origin, xp: r.xp, coins: r.coins);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    if (r.levelUp && r.newLevel > 0) {
      _sfx().questLevelUp();
      await showQuestLevelUp(context, r.newLevel);
    }
    for (final key in r.newBadgeKeys) {
      if (!mounted) return;
      _sfx().questBadge();
      await showQuestBadgeUnlocked(context, key);
    }
  }

  void _snack(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            error ? context.colors.danger : context.colors.accentPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── UI ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final s = S.of(context);
    final data = widget.data;
    final daily = data.quests.where((q) => q.frequency == 'daily').toList();
    final weekly = data.quests.where((q) => q.frequency == 'weekly').toList();
    final event = data.quests.where((q) => q.frequency == 'event').toList();
    final claimable = data.quests.where((q) => q.isClaimable).length;

    var index = 0;
    List<Widget> section(String title, List<DailyQuest> quests) {
      if (quests.isEmpty) return const [];
      return [
        const SizedBox(height: 22),
        StaggerIn(index: index++, child: _SectionTitle(title: title, count: quests.length)),
        const SizedBox(height: 10),
        for (final q in quests)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: StaggerIn(
              index: index++,
              child: _QuestCard(
                key: q.questKey == widget.highlightKey ? _highlightAnchor : null,
                quest: q,
                highlighted: q.questKey == widget.highlightKey,
                onClaim: (origin) => _claimOne(q, origin),
              ),
            ),
          ),
      ];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToHighlight());

    return RefreshIndicator(
      color: context.colors.accentPrimary,
      onRefresh: () async {
        await ref.read(questsViewModelProvider.notifier).refresh();
        ref.invalidate(questJourneyProvider);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        children: [
          StaggerIn(
            index: index++,
            child: QuestHeroCard(
              profile: data.profile,
              streak: data.streak,
              resetInSeconds: data.resetInSeconds,
              avatarUrl: widget.avatarUrl,
            ),
          ),
          const SizedBox(height: 14),
          StaggerIn(index: index++, child: _DayProgressCard(data: data)),
          if (claimable >= 2) ...[
            const SizedBox(height: 14),
            StaggerIn(
              index: index++,
              child: _ClaimAllButton(
                count: claimable,
                busy: _claimingAll,
                onTap: _claimAll,
              ),
            ),
          ],
          if (data.quests.isEmpty) ...[
            const SizedBox(height: 40),
            _EmptyMissions(text: s.questsEmpty),
          ],
          ...section(s.questsSectionDaily, daily),
          ...section(s.questsSectionWeekly, weekly),
          ...section(s.questsSectionEvent, event),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Progresso do dia + mascote
// ════════════════════════════════════════════════════════════════════════

class _DayProgressCard extends StatelessWidget {
  const _DayProgressCard({required this.data});
  final QuestsData data;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final daily = data.quests.where((q) => q.frequency == 'daily').toList();
    final list = daily.isNotEmpty ? daily : data.quests;
    final done = list.where((q) => q.isClaimed).length;
    final allDone = list.isNotEmpty && done == list.length;

    final String mascot;
    final String message;
    if (allDone) {
      mascot = 'assets/images/quests/mascot_celebrate.png';
      message = s.questsAllDoneMascot;
    } else if (data.streak.current >= 1) {
      mascot = 'assets/images/quests/mascot_fire.png';
      message = s.questsStreakMascot(data.streak.current);
    } else {
      mascot = 'assets/images/quests/empty_state.png';
      message = s.questsStartMascot;
    }

    return GameTile(
      tint: allDone ? colors.success : colors.accentPrimary,
      child: Row(
        children: [
          Floating(
            amplitude: 5,
            tilt: 0.06,
            child: Image.asset(
              mascot,
              width: 74,
              height: 74,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox(width: 74, height: 74),
            ),
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
                        s.questsDayProgress(done, list.length),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    _MiniStat(
                      icon: Icons.bolt_rounded,
                      color: const Color(0xFF7C5CFF),
                      value: '+${data.summary.totalXpToday}',
                    ),
                    const SizedBox(width: 6),
                    _MiniStat(
                      icon: Icons.monetization_on_rounded,
                      color: const Color(0xFFFFB800),
                      value: '+${data.summary.totalCoinsToday}',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Um segmento por missão.
                Row(
                  children: [
                    for (var i = 0; i < list.length; i++) ...[
                      if (i > 0) const SizedBox(width: 4),
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(
                            end: list[i].isClaimed
                                ? 1
                                : list[i].progressPercent / 100,
                          ),
                          duration: Duration(milliseconds: 600 + i * 120),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, _) => _Segment(
                            value: v,
                            colors: list[i].isClaimed
                                ? [colors.success, colors.success]
                                : paletteForQuest(list[i]).colors,
                            background: colors.surfaceHighest,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  maxLines: 3,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12.5,
                    height: 1.3,
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

class _Segment extends StatelessWidget {
  const _Segment({
    required this.value,
    required this.colors,
    required this.background,
  });

  final double value;
  final List<Color> colors;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.color,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Título de seção / Coletar tudo / vazio
// ════════════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});
  final String title;
  final int count;

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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: colors.surfaceHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ClaimAllButton extends StatelessWidget {
  const _ClaimAllButton({
    required this.count,
    required this.busy,
    required this.onTap,
  });

  final int count;
  final bool busy;
  final ValueChanged<Offset> onTap;

  @override
  Widget build(BuildContext context) {
    return Pulse(
      enabled: !busy,
      minScale: 0.98,
      maxScale: 1.02,
      child: Builder(
        builder: (btnCtx) => Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: busy ? null : () => onTap(_centerOf(btnCtx)),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD93D), Color(0xFFFF8B33), Color(0xFFFF4D8D)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8B33).withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ShineSweep(
                opacity: 0.45,
                borderRadius: BorderRadius.circular(18),
                period: const Duration(milliseconds: 2400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/quests/reward_chest.png',
                        width: 40,
                        height: 36,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.celebration_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (busy)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      else
                        Text(
                          S.of(context).questsClaimAll(count),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            shadows: [
                              Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyMissions extends StatelessWidget {
  const _EmptyMissions({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/quests/empty_state.png',
          height: 150,
          errorBuilder: (_, _, _) => const SizedBox(height: 150),
        ),
        const SizedBox(height: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}

Offset _centerOf(BuildContext ctx) {
  final box = ctx.findRenderObject() as RenderBox?;
  if (box == null || !box.hasSize) {
    final size = MediaQuery.sizeOf(ctx);
    return Offset(size.width / 2, size.height / 2);
  }
  return box.localToGlobal(box.size.center(Offset.zero));
}

// ════════════════════════════════════════════════════════════════════════
// Cartão da missão
// ════════════════════════════════════════════════════════════════════════

class _QuestCard extends StatefulWidget {
  const _QuestCard({
    super.key,
    required this.quest,
    required this.onClaim,
    this.highlighted = false,
  });

  final DailyQuest quest;
  final ValueChanged<Offset> onClaim;
  final bool highlighted;

  @override
  State<_QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<_QuestCard>
    with SingleTickerProviderStateMixin {
  /// Brilho da borda: pulsa quando dá para coletar ou quando a missão veio
  /// de uma notificação.
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    _syncGlow();
    if (widget.highlighted) {
      // Destaque temporário de quem veio pela notificação.
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) _syncGlow();
      });
    }
  }

  @override
  void didUpdateWidget(covariant _QuestCard old) {
    super.didUpdateWidget(old);
    _syncGlow();
  }

  void _syncGlow() {
    final on = widget.quest.isClaimable || widget.highlighted;
    if (on && !_glow.isAnimating) {
      _glow.repeat(reverse: true);
    } else if (!on && _glow.isAnimating) {
      _glow.stop();
      _glow.value = 0;
    }
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final q = widget.quest;
    final colors = context.colors;
    final palette = paletteForQuest(q);
    final claimed = q.isClaimed;
    final claimable = q.isClaimable;
    final title = q.title.isNotEmpty ? q.title : _fallbackTitle(s, q.actionType);

    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        final g = Curves.easeInOut.transform(_glow.value);
        final active = claimable || (widget.highlighted && _glow.isAnimating);
        return GameTile(
          tint: claimed ? colors.success : palette.end,
          glow: active ? 0.4 + 0.6 * g : 0,
          borderColor: active
              ? Color.lerp(palette.start, palette.end, g)!
              : null,
          padding: EdgeInsets.zero,
          child: child!,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Sparkles(
                      enabled: claimable,
                      child: Floating(
                        enabled: !claimed,
                        amplitude: claimable ? 5 : 3,
                        phase: (q.questKey.hashCode % 100) / 100,
                        child: QuestArt(
                          icon: q.icon,
                          category: q.category,
                          actionType: q.actionType,
                          size: 60,
                          dimmed: claimed,
                        ),
                      ),
                    ),
                    if (claimed)
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.surface, width: 2),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (q.isWeekly || q.isEvent || isLiveQuestAction(q.actionType) || q.category == 'live')
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (q.isWeekly)
                                _Tag(color: palette.end, label: s.questFrequencyWeekly),
                              if (q.isEvent)
                                _Tag(color: palette.end, label: s.questFrequencyEvent),
                              if (isLiveQuestAction(q.actionType) || q.category == 'live')
                                _Tag(color: palette.start, label: s.questLiveTag),
                            ],
                          ),
                        ),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: claimed ? colors.textSecondary : colors.textPrimary,
                          decoration: claimed ? TextDecoration.lineThrough : null,
                          decorationColor: colors.textTertiary,
                        ),
                      ),
                      if (q.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          q.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: colors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (q.xpReward > 0)
                            _RewardChip(
                              icon: Icons.bolt_rounded,
                              text: s.questsRewardXp(q.xpReward),
                              color: const Color(0xFF7C5CFF),
                              faded: claimed,
                            ),
                          if (q.coinsReward > 0)
                            _RewardChip(
                              icon: Icons.monetization_on_rounded,
                              text: s.questsRewardCoins(q.coinsReward),
                              color: const Color(0xFFFFB800),
                              faded: claimed,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            QuestProgressBar(
              value: claimed ? 1 : q.progressPercent / 100,
              colors: claimed ? [colors.success, colors.success] : palette.colors,
              background: colors.surfaceHighest,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  s.questsProgressCount(
                    claimed ? q.targetCount : q.currentCount,
                    q.targetCount,
                  ),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: claimed
                      ? _StatusPill(
                          key: const ValueKey('claimed'),
                          text: s.questsStatusClaimed,
                          color: colors.success,
                          icon: Icons.check_circle_rounded,
                        )
                      : claimable
                          ? _ClaimButton(
                              key: const ValueKey('claim'),
                              colors: palette.colors,
                              label: s.questsActionClaim,
                              onTap: widget.onClaim,
                            )
                          : _StatusPill(
                              key: const ValueKey('progress'),
                              text: s.questsStatusInProgress,
                              color: colors.textTertiary,
                            ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _fallbackTitle(S s, String actionType) {
    switch (actionType) {
      case 'watch_live':
        return s.questWatchLive;
      case 'send_live_gift':
        return s.questSendLiveGift;
      case 'live_chat':
        return s.questLiveChat;
      case 'live_like':
        return s.questLiveLike;
      default:
        return '';
    }
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({
    required this.icon,
    required this.text,
    required this.color,
    this.faded = false,
  });

  final IconData icon;
  final String text;
  final Color color;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final c = faded ? context.colors.textTertiary : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: context.isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(color: c, fontSize: 11.5, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    super.key,
    required this.text,
    required this.color,
    this.icon,
  });

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ClaimButton extends StatefulWidget {
  const _ClaimButton({
    super.key,
    required this.colors,
    required this.label,
    required this.onTap,
  });

  final List<Color> colors;
  final String label;
  final ValueChanged<Offset> onTap;

  @override
  State<_ClaimButton> createState() => _ClaimButtonState();
}

class _ClaimButtonState extends State<_ClaimButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Pulse(
      minScale: 0.96,
      maxScale: 1.05,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap(_centerOf(context));
        },
        child: AnimatedScale(
          scale: _pressed ? 0.9 : 1,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: widget.colors),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.colors.last.withValues(alpha: 0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.redeem_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 5),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
