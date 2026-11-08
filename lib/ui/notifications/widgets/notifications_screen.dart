import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/services/notification_navigation_service.dart';
import '../../../domain/models/app_notification.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../shared/widgets/brawe_illustration.dart';
import '../notification_presentation.dart';
import '../view_models/notifications_view_model.dart';
import 'notification_sections.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotifFilter _filter = NotifFilter.all;

  void _open(AppNotification n) {
    if (!n.isRead) {
      ref.read(notificationsViewModelProvider.notifier).markRead(n.id);
    }
    // Grupo de novos seguidores: abre a lista de quem seguiu.
    if (NotifPresentation.isFollowGroup(n)) {
      context.push('/notifications/${n.id}/followers');
      return;
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

          final unreadBy = <NotifFilter, int>{};
          for (final n in page.items) {
            final c = NotifPresentation.filterOf(n);
            if (c != null && !n.isRead) unreadBy[c] = (unreadBy[c] ?? 0) + 1;
          }
          final items = page.items
              .where((n) => NotifPresentation.matches(_filter, n))
              .toList();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  NotificationFilterBar(
                    selected: _filter,
                    unreadBy: unreadBy,
                    totalUnread: page.unreadCount,
                    onSelect: (f) => setState(() => _filter = f),
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
                                key: ValueKey('empty-$_filter'),
                                physics: const AlwaysScrollableScrollPhysics(),
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
                            : NotificationSectionsList(
                                key: ValueKey('list-$_filter'),
                                items: items,
                                onOpen: _open,
                                onRemove: (n) => ref
                                    .read(
                                      notificationsViewModelProvider.notifier,
                                    )
                                    .remove(n.id),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const BraweIllustrationView(BraweIllustration.bell, size: 96),
              const SizedBox(height: 12),
              Text(
                s.notificationsEmptyTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.notificationsEmptySubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
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
          Icon(
            LucideIcons.circleAlert,
            size: 40,
            color: context.colors.textTertiary,
          ),
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
