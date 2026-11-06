import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/live_dio_provider.dart';

part 'notifications_service.g.dart';

@riverpod
NotificationsService notificationsService(Ref ref) {
  return NotificationsService(ref.watch(liveDioProvider));
}

class NotificationsService {
  final Dio _dio;
  NotificationsService(this._dio);

  Future<Map<String, dynamic>> list({
    int page = 1,
    int limit = 20,
    bool? isRead,
    String? category,
  }) async {
    final r = await _dio.get(
      '/notifications',
      queryParameters: {
        'page': page,
        'limit': limit,
        'is_read': ?isRead,
        'category': ?category,
      },
    );
    final data = r.data;
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  /// Quem está num grupo (ex.: novos seguidores de `follow:{user}:{dia}`).
  Future<List<Map<String, dynamic>>> actors(String id, {int limit = 50}) async {
    final r = await _dio.get(
      '/notifications/$id/actors',
      queryParameters: {'limit': limit},
    );
    final data = r.data;
    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    }
    return const [];
  }

  Future<int> unreadCount() async {
    final r = await _dio.get('/notifications/unread-count');
    final data = r.data;
    if (data is Map<String, dynamic>) {
      return (data['unread_count'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  Future<void> markRead(String id) async {
    await _dio.put('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _dio.put('/notifications/read-all');
  }

  Future<void> delete(String id) async {
    await _dio.delete('/notifications/$id');
  }
}
