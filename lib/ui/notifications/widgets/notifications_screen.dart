import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/app_notification.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../view_models/notifications_view_model.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final async = ref.watch(notificationsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.notificationsTitle),
        leading: const BackButton(),
        actions: [
          async.when(
            data: (p) => p.unreadCount > 0
                ? TextButton.icon(
                    onPressed: () => ref
                        .read(notificationsViewModelProvider.notifier)
                        .markAllRead(),
                    icon: const Icon(Icons.done_all, size: 18),
                    label: Text(s.notificationsMarkAll),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          onRetry: () =>
              ref.read(notificationsViewModelProvider.notifier).refresh(),
        ),
        data: (page) => RefreshIndicator(
          onRefresh: () =>
              ref.read(notificationsViewModelProvider.notifier).refresh(),
          child: page.items.isEmpty
              ? _EmptyView()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: page.items.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                    indent: 72,
                  ),
                  itemBuilder: (_, i) {
                    final n = page.items[i];
                    return Dismissible(
                      key: ValueKey(n.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: context.colors.danger,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete,
                            color: context.colors.textOnAccent),
                      ),
                      onDismissed: (_) => ref
                          .read(notificationsViewModelProvider.notifier)
                          .remove(n.id),
                      child: _NotificationTile(
                        notification: n,
                        onTap: () {
                          if (!n.isRead) {
                            ref
                                .read(notificationsViewModelProvider.notifier)
                                .markRead(n.id);
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unread = !notification.isRead;
    final (icon, color) = _iconFor(notification.type);

    return Material(
      color: unread
          ? context.colors.accentPrimary.withValues(alpha: 0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: color.withValues(alpha: 0.15),
                    backgroundImage: (notification.actorAvatar != null &&
                            notification.actorAvatar!.isNotEmpty)
                        ? NetworkImage(notification.actorAvatar!)
                        : null,
                    child: (notification.actorAvatar == null ||
                            notification.actorAvatar!.isEmpty)
                        ? Icon(icon, color: color, size: 22)
                        : null,
                  ),
                  if (unread)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: context.colors.accentPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight:
                            unread ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurface.withValues(alpha: 0.7),
                        height: 1.35,
                      ),
                    ),
                    if (notification.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _timeAgo(context, notification.createdAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color) _iconFor(String type) {
    switch (type) {
      case 'follow':
        return (Icons.person_add_alt_1, AppColors.electricPurple);
      case 'like':
        return (Icons.favorite, AppColors.mutedRed);
      case 'comment':
      case 'reply':
        return (Icons.chat_bubble_outline, AppColors.coolCyan);
      case 'gift':
        return (Icons.card_giftcard, Colors.amber);
      case 'live_start':
        return (Icons.live_tv, AppColors.mutedRed);
      case 'message':
        return (Icons.mail_outline, AppColors.coolCyan);
      case 'quest':
        return (Icons.emoji_events, AppColors.electricPurple);
      default:
        return (Icons.notifications, AppColors.electricPurple);
    }
  }

  static String _timeAgo(BuildContext context, DateTime dt) {
    final s = S.of(context);
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return s.notificationsTimeNow;
    if (diff.inMinutes < 60) return s.notificationsTimeMinutes(diff.inMinutes);
    if (diff.inHours < 24) return s.notificationsTimeHours(diff.inHours);
    if (diff.inDays < 7) return s.notificationsTimeDays(diff.inDays);
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ListView(
      children: [
        const SizedBox(height: 100),
        Icon(
          Icons.notifications_none_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            s.notificationsEmptyTitle,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            s.notificationsEmptySubtitle,
            style: TextStyle(
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
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
