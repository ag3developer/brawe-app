import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/live_dio_provider.dart';

part 'social_actions_service.g.dart';

/// Block & Report actions (mounted at /messages/* in backend).
class SocialActionsService {
  final Dio _dio;
  SocialActionsService(this._dio);

  Future<void> blockUser(String slug) async {
    await _dio.post('/messages/blocks/$slug');
  }

  Future<void> unblockUser(String slug) async {
    await _dio.delete('/messages/blocks/$slug');
  }

  Future<List<String>> listBlockedIds() async {
    final r = await _dio.get('/messages/blocks');
    final raw = r.data;
    final list = (raw is Map ? raw['data'] : raw) as List? ?? const [];
    return list
        .map((e) => (e['blocked_id'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// [targetType] in: user | message | conversation | post
  /// [reason]    in: spam | harassment | inappropriate | impersonation | other
  Future<void> report({
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
  }) async {
    await _dio.post('/messages/reports', data: {
      'target_type': targetType,
      'target_id': targetId,
      'reason': reason,
      if (details != null && details.isNotEmpty) 'details': details,
    });
  }
}

@riverpod
SocialActionsService socialActionsService(Ref ref) {
  return SocialActionsService(ref.watch(liveDioProvider));
}
