import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/quest_journey.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../live/shared/widgets/award_badge.dart' show awardColor;
import '../view_models/quests_view_model.dart';
import 'quest_achievements_tab.dart';
import 'quest_visuals.dart';

/// Aba "Jornada": linha do tempo de missões, prêmios, emblemas e níveis.
class QuestTimelineTab extends ConsumerStatefulWidget {
  const QuestTimelineTab({super.key});

  @override
  ConsumerState<QuestTimelineTab> createState() => _QuestTimelineTabState();
}

class _QuestTimelineTabState extends ConsumerState<QuestTimelineTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final s = S.of(context);
    final async = ref.watch(questJourneyProvider);
    return async.when(
      loading: () => const QuestJourneyLoading(),
      error: (_, _) => QuestJourneyError(
        onRetry: () => ref.read(questJourneyProvider.notifier).refresh(),
      ),
      data: (j) {
        final rows = _buildRows(context, j.timeline);
        return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.extentAfter < 400) {
              ref.read(questJourneyProvider.notifier).loadMore();
            }
            return false;
          },
          child: RefreshIndicator(
            color: context.colors.accentPrimary,
            onRefresh: () => ref.read(questJourneyProvider.notifier).refresh(),
            child: j.timeline.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 110),
                    children: [
                      Floating(
                        child: Image.asset(
                          'assets/images/quests/empty_state.png',
                          height: 170,
                          errorBuilder: (_, _, _) => const SizedBox(height: 170),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        s.questsTimelineEmpty,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                    itemCount: rows.length + (j.hasMore ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i >= rows.length) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: context.colors.accentPrimary,
                              ),
                            ),
                          ),
                        );
                      }
                      return StaggerIn(index: i, child: rows[i]);
                    },
                  ),
          ),
        );
      },
    );
  }

  /// Cabeçalhos de dia + eventos, na ordem.
  List<Widget> _buildRows(BuildContext context, List<JourneyEvent> events) {
    final out = <Widget>[];
    DateTime? lastDay;
    for (var i = 0; i < events.length; i++) {
      final e = events[i];
      final day = DateTime(e.at.year, e.at.month, e.at.day);
      if (lastDay == null || day != lastDay) {
        out.add(_DayHeader(day: day, first: lastDay == null));
        lastDay = day;
      }
      final next = i + 1 < events.length ? events[i + 1] : null;
      final sameDayNext = next != null &&
          DateTime(next.at.year, next.at.month, next.at.day) == day;
      out.add(_EventRow(event: e, last: !sameDayNext));
    }
    return out;
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.first});
  final DateTime day;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final String label;
    if (day == today) {
      label = s.questsTimelineToday;
    } else if (day == today.subtract(const Duration(days: 1))) {
      label = s.questsTimelineYesterday;
    } else {
      label = DateFormat.MMMMEEEEd(locale).format(day);
    }
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.only(top: first ? 0 : 18, bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.accentPrimary, colors.accentSecondary],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label[0].toUpperCase() + label.substring(1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: colors.divider)),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.last});
  final JourneyEvent event;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final time = DateFormat.Hm(Localizations.localeOf(context).toLanguageTag())
        .format(event.at);

    late final Color nodeColor;
    late final Widget node;
    late final String kicker;
    late final Widget content;

    switch (event.kind) {
      case 'award':
        final a = event.award;
        nodeColor = awardColor(a?.award.badgeColor);
        node = const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 16);
        kicker = s.questsTimelineAward;
        content = a == null
            ? const SizedBox.shrink()
            : QuestAwardTile(award: a, compact: true);
      case 'badge':
        final key = event.badgeKey ?? '';
        nodeColor = questBadgeColors(key).last;
        node = Text(event.emoji ?? questBadgeEmoji(key), style: const TextStyle(fontSize: 13));
        kicker = s.questsTimelineBadge;
        content = Row(
          children: [
            QuestBadgeMedal(badgeKey: key, unlocked: true, size: 46, animate: false),
            const SizedBox(width: 12),
            Expanded(child: _Title(questBadgeName(s, key))),
          ],
        );
      case 'level_up':
        nodeColor = const Color(0xFF7C5CFF);
        node = const Icon(Icons.trending_up_rounded, color: Colors.white, size: 16);
        kicker = s.questsTimelineLevel(event.level ?? 0);
        content = Row(
          children: [
            Image.asset(
              'assets/images/illustrations/trophy_3d.png',
              width: 46,
              height: 46,
              errorBuilder: (_, _, _) => const SizedBox(width: 46),
            ),
            const SizedBox(width: 12),
            Expanded(child: _Title(s.questsLevelUpBody(event.level ?? 0))),
          ],
        );
      default:
        final palette = questPalette(
          category: event.category ?? '',
          actionType: event.actionType ?? '',
        );
        nodeColor = palette.end;
        node = const Icon(Icons.check_rounded, color: Colors.white, size: 16);
        kicker = s.questsTimelineQuest;
        content = Row(
          children: [
            QuestArt(
              icon: event.icon,
              category: event.category,
              actionType: event.actionType ?? '',
              size: 44,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Title(event.title ?? ''),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: [
                      if (event.xp > 0)
                        _Gain(
                          icon: Icons.bolt_rounded,
                          text: '+${event.xp} XP',
                          color: const Color(0xFF7C5CFF),
                        ),
                      if (event.coins > 0)
                        _Gain(
                          icon: Icons.monetization_on_rounded,
                          text: '+${event.coins}',
                          color: const Color(0xFFFFB800),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Trilho + nó.
          SizedBox(
            width: 34,
            child: Column(
              children: [
                const SizedBox(height: 14),
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: nodeColor,
                    border: Border.all(color: colors.background, width: 3),
                    boxShadow: [
                      BoxShadow(color: nodeColor.withValues(alpha: 0.5), blurRadius: 8),
                    ],
                  ),
                  child: node,
                ),
                Expanded(
                  child: last
                      ? const SizedBox.shrink()
                      : Container(
                          width: 3,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                nodeColor.withValues(alpha: 0.7),
                                colors.divider,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GameTile(
                tint: nodeColor,
                depth: 4,
                radius: 20,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            kicker.toUpperCase(),
                            style: TextStyle(
                              color: nodeColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            color: colors.textTertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    content,
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

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: context.colors.textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 14,
      ),
    );
  }
}

class _Gain extends StatelessWidget {
  const _Gain({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12),
        ),
      ],
    );
  }
}
