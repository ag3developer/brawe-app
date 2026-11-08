import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../domain/models/app_notification.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../notification_presentation.dart';
import 'notification_tile.dart';

String notifFilterLabel(S s, NotifFilter f) => switch (f) {
  NotifFilter.all => s.notifFilterAll,
  NotifFilter.likes => s.notifFilterLikes,
  NotifFilter.comments => s.notifFilterComments,
  NotifFilter.followers => s.notifFilterFollowers,
  NotifFilter.gifts => s.notifFilterGifts,
  NotifFilter.mentions => s.notifFilterMentions,
  NotifFilter.brawe => s.notifFilterBrawe,
};

/// Chips de filtro (rolagem horizontal; a altura acompanha a escala do texto).
class NotificationFilterBar extends StatelessWidget {
  const NotificationFilterBar({
    super.key,
    required this.selected,
    required this.unreadBy,
    required this.totalUnread,
    required this.onSelect,
  });

  final NotifFilter selected;
  final Map<NotifFilter, int> unreadBy;
  final int totalUnread;
  final ValueChanged<NotifFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scale = MediaQuery.textScalerOf(context);
    final h = scale.scale(34) + 14;
    return SizedBox(
      height: h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        itemCount: NotifFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = NotifFilter.values[i];
          final count = f == NotifFilter.all ? totalUnread : (unreadBy[f] ?? 0);
          return _FilterChip(
            key: ValueKey('notif-chip-${f.name}'),
            label: notifFilterLabel(s, f),
            count: count,
            selected: f == selected,
            onTap: () => onSelect(f),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.textPrimary : colors.surfaceHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? colors.background : colors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: colors.danger,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: TextStyle(
                      color: colors.textOnAccent,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Lista com seções: Hoje, Esta semana, Este mês, Anteriores (já na ordem recebida).
class NotificationSectionsList extends StatelessWidget {
  const NotificationSectionsList({
    super.key,
    required this.items,
    required this.onOpen,
    required this.onRemove,
    this.now,
  });

  final List<AppNotification> items;
  final ValueChanged<AppNotification> onOpen;
  final ValueChanged<AppNotification> onRemove;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final titles = {
      NotifBucket.today: s.notifGroupToday,
      NotifBucket.week: s.notifGroupWeek,
      NotifBucket.month: s.notifGroupMonth,
      NotifBucket.older: s.notifGroupOlder,
    };
    final clock = now ?? DateTime.now();

    final rows = <Widget>[];
    NotifBucket? last;
    for (final n in items) {
      final b = NotifPresentation.bucketOf(n.createdAt, clock);
      if (b != last) {
        rows.add(
          Padding(
            key: ValueKey('notif-section-${b.name}'),
            padding: const EdgeInsets.fromLTRB(18, 16, 16, 4),
            child: Semantics(
              header: true,
              child: Text(
                titles[b]!,
                style: TextStyle(
                  color: colors.textTertiary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
        last = b;
      }
      rows.add(
        Dismissible(
          key: ValueKey(n.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: colors.danger,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Icon(LucideIcons.trash2, color: colors.textOnAccent),
          ),
          onDismissed: (_) => onRemove(n),
          child: NotificationTile(notification: n, onTap: () => onOpen(n)),
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: rows,
    );
  }
}
