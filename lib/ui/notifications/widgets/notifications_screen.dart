import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/services/notification_navigation_service.dart';
import '../../../core/text/brawe_rich_text.dart';
import 'package:brawe_app/ui/core/ui/verified_badge.dart';
import '../../../domain/models/app_notification.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../shared/widgets/brawe_illustration.dart';
import '../view_models/notifications_view_model.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// Categorias do filtro (chips no topo).
enum _NotifFilter { all, lives, social, missions, gifts, other }

/// Em qual categoria cada tipo de notificação cai.
_NotifFilter _categoryOf(AppNotification n) {
  final kind = n.data?['kind']?.toString() ?? '';
  if (kind.startsWith('daily_quest') || kind.contains('quest')) {
    return _NotifFilter.missions;
  }
  switch (n.type) {
    case 'live_start':
    case 'live_started':
    case 'live_starting':
    case 'battle_invite':
    case 'mystery_gifter_live':
      return _NotifFilter.lives;
    case 'follow':
    case 'like':
    case 'post_liked':
    case 'comment':
    case 'post_commented':
    case 'reply':
    case 'comment_replied':
    case 'comment_mention':
    case 'new_post':
    case 'story_reaction':
    case 'story_reply':
    case 'message':
    case 'new_message':
      return _NotifFilter.social;
    case 'quest':
    case 'quest_completed':
    case 'quest_reminder':
    case 'award_received':
    case 'creator_level_up':
      return _NotifFilter.missions;
    case 'gift':
    case 'gift_received':
    case 'mystery_gift_received':
    case 'mystery_gift_revealed':
    case 'purchase':
      return _NotifFilter.gifts;
    default:
      return _NotifFilter.other;
  }
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  _NotifFilter _filter = _NotifFilter.all;

  String _label(S s, _NotifFilter f) => switch (f) {
    _NotifFilter.all => s.notifFilterAll,
    _NotifFilter.lives => s.notifFilterLives,
    _NotifFilter.social => s.notifFilterSocial,
    _NotifFilter.missions => s.notifFilterMissions,
    _NotifFilter.gifts => s.notifFilterGifts,
    _NotifFilter.other => s.notifFilterOther,
  };

  void _open(AppNotification n) {
    if (!n.isRead) {
      ref.read(notificationsViewModelProvider.notifier).markRead(n.id);
    }
    // A rota vem em `data.route` (backend) com fallback para `link_url`.
    ref.read(notificationNavigationServiceProvider).handleData({
      if (n.linkUrl != null) 'link_url': n.linkUrl,
      ...?n.data,
      'type': n.type,
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final async = ref.watch(notificationsViewModelProvider);
    final page = async.value;
    final hasUnread = (page?.unreadCount ?? 0) > 0;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          s.notificationsTitle,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: const BackButton(),
        actions: [
          if (hasUnread)
            IconButton(
              tooltip: s.notifMarkAllTooltip,
              icon: Icon(LucideIcons.checkCheck, color: colors.accentPrimary),
              onPressed: () => ref
                  .read(notificationsViewModelProvider.notifier)
                  .markAllRead(),
            ),
        ],
      ),
      body: async.when(
        skipLoadingOnRefresh: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          onRetry: () =>
              ref.read(notificationsViewModelProvider.notifier).refresh(),
        ),
        data: (page) {
          if (page.items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(notificationsViewModelProvider.notifier).refresh(),
              child: _EmptyView(),
            );
          }

          // Só mostra chips de categorias que têm algo (exceto "Todas").
          final unreadBy = <_NotifFilter, int>{};
          final present = <_NotifFilter>{};
          for (final n in page.items) {
            final c = _categoryOf(n);
            present.add(c);
            if (!n.isRead) unreadBy[c] = (unreadBy[c] ?? 0) + 1;
          }
          final filters = [
            _NotifFilter.all,
            for (final f in _NotifFilter.values.skip(1))
              if (present.contains(f)) f,
          ];
          final filter = filters.contains(_filter) ? _filter : _NotifFilter.all;
          final items = filter == _NotifFilter.all
              ? page.items
              : page.items.where((n) => _categoryOf(n) == filter).toList();

          return Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                  itemCount: filters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final f = filters[i];
                    final count = f == _NotifFilter.all
                        ? page.unreadCount
                        : (unreadBy[f] ?? 0);
                    return _FilterChip(
                      label: _label(s, f),
                      count: count,
                      selected: f == filter,
                      onTap: () => setState(() => _filter = f),
                    );
                  },
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref
                      .read(notificationsViewModelProvider.notifier)
                      .refresh(),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: items.isEmpty
                        ? ListView(
                            key: ValueKey('empty-$filter'),
                            children: [
                              const SizedBox(height: 80),
                              Icon(
                                LucideIcons.inbox,
                                size: 40,
                                color: colors.textTertiary,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                s.notifFilterEmpty,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : _GroupedList(
                            key: ValueKey('list-$filter'),
                            items: items,
                            onOpen: _open,
                            onRemove: (n) => ref
                                .read(notificationsViewModelProvider.notifier)
                                .remove(n.id),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
    return GestureDetector(
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lista agrupada por data: Hoje, Ontem, Esta semana, Anteriores.
class _GroupedList extends StatelessWidget {
  const _GroupedList({
    super.key,
    required this.items,
    required this.onOpen,
    required this.onRemove,
  });

  final List<AppNotification> items;
  final ValueChanged<AppNotification> onOpen;
  final ValueChanged<AppNotification> onRemove;

  int _bucket(DateTime? dt) {
    if (dt == null) return 3;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final local = dt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return 0;
    if (diff == 1) return 1;
    if (diff < 7) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final titles = [
      s.notifGroupToday,
      s.notifGroupYesterday,
      s.notifGroupWeek,
      s.notifGroupOlder,
    ];

    final rows = <Widget>[];
    int? last;
    for (final n in items) {
      final b = _bucket(n.createdAt);
      if (b != last) {
        rows.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              titles[b],
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
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
          child: _NotificationTile(notification: n, onTap: () => onOpen(n)),
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

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final n = notification;
    final unread = !n.isRead;
    final (icon, color) = _iconFor(n);
    final hasAvatar = n.actorAvatar != null && n.actorAvatar!.isNotEmpty;
    final xp = (n.data?['xp_reward'] as num?)?.toInt();

    Widget typeIcon(double size, double iconSize) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          color.withValues(alpha: 0.16),
          colors.background,
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: iconSize),
    );

    final leading = SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (hasAvatar)
            ClipOval(
              child: CachedNetworkImage(
                memCacheWidth: context.decodePx(48),
                imageUrl: n.actorAvatar!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 150),
                placeholder: (_, _) => typeIcon(48, 22),
                errorWidget: (_, _, _) => typeIcon(48, 22),
              ),
            )
          else
            typeIcon(48, 22),
          // Com foto: selo pequeno do tipo no canto (estilo Instagram).
          if (hasAvatar)
            Positioned(
              right: -3,
              bottom: -3,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.background, width: 2),
                ),
                child: Icon(icon, size: 11, color: Colors.white),
              ),
            ),
        ],
      ),
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        color: unread
            ? colors.accentPrimary.withValues(alpha: 0.06)
            : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 10, 14, 10),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        ..._titleSpans(
                          n,
                          TextStyle(
                            fontWeight: unread
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                        if (n.createdAt != null)
                          TextSpan(
                            text: '  ${_timeAgo(context, n.createdAt!)}',
                            style: TextStyle(
                              color: colors.textTertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textPrimary, fontSize: 14),
                  ),
                  if (n.message.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      BraweRichText.humanize(
                        n.message,
                        sharedPostLabel: S.of(context).linkSharedPost,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (xp != null && xp > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+$xp XP',
                  style: const TextStyle(
                    color: Color(0xFFD97706),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            else if (unread)
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: colors.accentPrimary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Título com o selo de verificado logo após o nome do autor
  /// ("Fulano ✔︎ está ao vivo"). Sem nome no início, o selo vai no fim.
  List<InlineSpan> _titleSpans(AppNotification n, TextStyle style) {
    if (!n.actorIsVerified) return [TextSpan(text: n.title, style: style)];
    final name = n.actorName?.trim() ?? '';
    if (name.isNotEmpty && n.title.startsWith(name)) {
      return [
        TextSpan(text: name, style: style),
        VerifiedBadge.span(size: 13, gap: 3),
        TextSpan(text: n.title.substring(name.length), style: style),
      ];
    }
    return [
      TextSpan(text: n.title, style: style),
      VerifiedBadge.span(size: 13, gap: 3),
    ];
  }

  (IconData, Color) _iconFor(AppNotification n) {
    if (_categoryOf(n) == _NotifFilter.missions &&
        (n.type == 'system' ||
            n.type == 'quest' ||
            n.type == 'quest_completed')) {
      return (LucideIcons.trophy, const Color(0xFFF59E0B));
    }
    switch (n.type) {
      case 'follow':
        return (LucideIcons.userPlus, const Color(0xFF3B82F6));
      case 'like':
      case 'post_liked':
      case 'story_reaction':
        return (LucideIcons.heart, const Color(0xFFEF4444));
      case 'comment':
      case 'post_commented':
      case 'story_reply':
        return (LucideIcons.messageCircle, const Color(0xFF0EA5E9));
      case 'reply':
      case 'comment_replied':
        return (LucideIcons.cornerUpLeft, const Color(0xFF0EA5E9));
      case 'comment_mention':
        return (LucideIcons.atSign, const Color(0xFF8B5CF6));
      case 'gift':
      case 'gift_received':
      case 'mystery_gift_received':
      case 'mystery_gift_revealed':
        return (LucideIcons.gift, const Color(0xFFF59E0B));
      case 'live_start':
      case 'live_started':
      case 'mystery_gifter_live':
        return (LucideIcons.radio, const Color(0xFFEF4444));
      case 'live_starting':
        return (LucideIcons.clock, const Color(0xFFF97316));
      case 'message':
      case 'new_message':
        return (LucideIcons.messageSquare, const Color(0xFF0EA5E9));
      case 'quest_reminder':
        return (LucideIcons.target, const Color(0xFFF59E0B));
      case 'new_post':
        return (LucideIcons.image, const Color(0xFF8B5CF6));
      case 'purchase':
        return (LucideIcons.shoppingBag, const Color(0xFF10B981));
      case 'battle_invite':
        return (LucideIcons.swords, const Color(0xFFEF4444));
      case 'creator_approved':
        return (LucideIcons.badgeCheck, const Color(0xFF3B82F6));
      case 'award_received':
        return (LucideIcons.award, const Color(0xFFF59E0B));
      case 'creator_level_up':
        return (LucideIcons.trendingUp, const Color(0xFF10B981));
      default:
        return (LucideIcons.bell, const Color(0xFF64748B));
    }
  }

  static String _timeAgo(BuildContext context, DateTime dt) {
    final s = S.of(context);
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return s.notificationsTimeNow;
    if (diff.inMinutes < 60) return s.notificationsTimeMinutes(diff.inMinutes);
    if (diff.inHours < 24) return s.notificationsTimeHours(diff.inHours);
    if (diff.inDays < 7) return s.notificationsTimeDays(diff.inDays);
    final local = dt.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: [
              const BraweIllustrationView(BraweIllustration.bell, size: 96),
              const SizedBox(height: 12),
              Text(
                s.notificationsEmptyTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.notificationsEmptySubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
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
          const Icon(Icons.error_outline, size: 40),
          const SizedBox(height: 12),
          Text(s.notificationsLoadError),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: Text(s.notificationsTryAgain),
          ),
        ],
      ),
    );
  }
}
