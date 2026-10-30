import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/services/notification_navigation_service.dart';
import '../../../domain/models/app_notification.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../shared/widgets/brawe_illustration.dart';
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
            error: (_, _) => const SizedBox.shrink(),
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
                  separatorBuilder: (_, _) => Divider(
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
                        child: Icon(
                          Icons.delete,
                          color: context.colors.textOnAccent,
                        ),
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
                          // Navega para o destino da notificação (post,
                          // perfil, live, chat...). A rota vem em `data.route`
                          // (enviada pelo backend) com fallback para `link_url`.
                          final nav = ref.read(
                            notificationNavigationServiceProvider,
                          );
                          if (n.data != null && n.data!.isNotEmpty) {
                            nav.handleData(n.data);
                          } else if (n.linkUrl != null) {
                            nav.handleRoute(n.linkUrl);
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
  const _NotificationTile({required this.notification, required this.onTap});

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
                  // Avatar do ator com cache em disco. Quando não há
                  // avatar, mostra o ícone do tipo de notificação (mais
                  // contextual que uma inicial — sabemos que foi curtida
                  // ou comentário).
                  ClipOval(
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: (notification.actorAvatar != null &&
                              notification.actorAvatar!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: notification.actorAvatar!,
                              fit: BoxFit.cover,
                              fadeInDuration:
                                  const Duration(milliseconds: 150),
                              placeholder: (_, _) => Container(
                                color: color.withValues(alpha: 0.15),
                              ),
                              errorWidget: (_, _, _) => Container(
                                color: color.withValues(alpha: 0.15),
                                alignment: Alignment.center,
                                child: Icon(icon, color: color, size: 22),
                              ),
                            )
                          : Container(
                              color: color.withValues(alpha: 0.15),
                              alignment: Alignment.center,
                              child: Icon(icon, color: color, size: 22),
                            ),
                    ),
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
                        fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
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
        return (LucideIcons.userPlus, AppColors.braweBlue);
      case 'like':
      case 'post_liked':
        return (LucideIcons.heart, AppColors.mutedRed);
      case 'comment':
      case 'post_commented':
        return (LucideIcons.messageCircle, AppColors.braweSky);
      case 'reply':
      case 'comment_replied':
        return (LucideIcons.cornerUpLeft, AppColors.braweSky);
      case 'gift':
      case 'gift_received':
        return (LucideIcons.gift, Colors.amber);
      case 'live_start':
      case 'live_started':
        return (LucideIcons.radio, AppColors.mutedRed);
      case 'live_starting':
        return (LucideIcons.clock, AppColors.mutedRed);
      case 'message':
      case 'new_message':
        return (LucideIcons.messageSquare, AppColors.braweSky);
      case 'quest':
      case 'quest_completed':
        return (LucideIcons.trophy, AppColors.braweBlue);
      case 'quest_reminder':
        return (LucideIcons.target, AppColors.braweBlue);
      case 'new_post':
        return (LucideIcons.image, AppColors.braweBlue);
      case 'purchase':
        return (LucideIcons.shoppingBag, Colors.green);
      case 'battle_invite':
        return (LucideIcons.swords, AppColors.mutedRed);
      case 'creator_approved':
        return (LucideIcons.badgeCheck, AppColors.braweBlue);
      case 'creator_level_up':
        return (LucideIcons.trendingUp, AppColors.braweBlue);
      default:
        return (LucideIcons.bell, AppColors.braweBlue);
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
