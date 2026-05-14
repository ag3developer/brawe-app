import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/app_notification.dart';
import '../../domain/models/failure.dart';
import '../services/notifications_service.dart';

part 'notifications_repository.g.dart';

@riverpod
NotificationsRepository notificationsRepository(Ref ref) {
  return NotificationsRepository(ref.watch(notificationsServiceProvider));
}

class NotificationsRepository {
  final NotificationsService _service;
  NotificationsRepository(this._service);

  Future<NotificationsPage> list({int page = 1, int limit = 20}) async {
    try {
      final json = await _service.list(page: page, limit: limit);
      return NotificationsPage.fromJson(json);
    } catch (_) {
      throw const Failure.network();
    }
  }

  Future<int> unreadCount() async {
    try {
      return await _service.unreadCount();
    } catch (_) {
      return 0;
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _service.markRead(id);
    } catch (_) {
      throw const Failure.network();
    }
  }

  Future<void> markAllRead() async {
    try {
      await _service.markAllRead();
    } catch (_) {
      throw const Failure.network();
    }
  }

  Future<void> delete(String id) async {
    try {
      await _service.delete(id);
    } catch (_) {
      throw const Failure.network();
    }
  }
}
