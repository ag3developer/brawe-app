// removed unused flutter_riverpod import
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/notifications_repository.dart';
import '../../../domain/models/app_notification.dart';
import '../../core/view_models/app_badge_controller.dart';

part 'notifications_view_model.g.dart';

@riverpod
class NotificationsViewModel extends _$NotificationsViewModel {
  @override
  Future<NotificationsPage> build() async {
    return ref.read(notificationsRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(notificationsRepositoryProvider).list(),
    );
  }

  Future<void> markRead(String id) async {
    final current = state.value;
    if (current == null) return;
    final idx = current.items.indexWhere((n) => n.id == id);
    if (idx < 0 || current.items[idx].isRead) return;

    final optimistic = [...current.items];
    optimistic[idx] = optimistic[idx].copyWith(isRead: true);
    state = AsyncValue.data(
      NotificationsPage(
        items: optimistic,
        total: current.total,
        unreadCount: (current.unreadCount - 1).clamp(0, 1 << 30),
      ),
    );

    try {
      await ref.read(notificationsRepositoryProvider).markRead(id);
      // Atualiza o badge do ícone (a contagem global vem de um provider à parte).
      ref.read(appBadgeControllerProvider.notifier).refresh();
    } catch (_) {
      state = AsyncValue.data(current);
    }
  }

  Future<void> markAllRead() async {
    final current = state.value;
    if (current == null) return;
    final optimistic =
        current.items.map((n) => n.copyWith(isRead: true)).toList();
    state = AsyncValue.data(
      NotificationsPage(
        items: optimistic,
        total: current.total,
        unreadCount: 0,
      ),
    );
    try {
      await ref.read(notificationsRepositoryProvider).markAllRead();
      ref.read(appBadgeControllerProvider.notifier).refresh();
    } catch (_) {
      state = AsyncValue.data(current);
    }
  }

  Future<void> remove(String id) async {
    final current = state.value;
    if (current == null) return;
    final removed = current.items.firstWhere(
      (n) => n.id == id,
      orElse: () => current.items.first,
    );
    final filtered = current.items.where((n) => n.id != id).toList();
    state = AsyncValue.data(
      NotificationsPage(
        items: filtered,
        total: (current.total - 1).clamp(0, 1 << 30),
        unreadCount: removed.isRead
            ? current.unreadCount
            : (current.unreadCount - 1).clamp(0, 1 << 30),
      ),
    );
    try {
      await ref.read(notificationsRepositoryProvider).delete(id);
    } catch (_) {
      state = AsyncValue.data(current);
    }
  }
}

/// Lightweight unread count provider.
@riverpod
Future<int> notificationsUnreadCount(Ref ref) async {
  return ref.read(notificationsRepositoryProvider).unreadCount();
}
