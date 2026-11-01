import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/live_dio_provider.dart';
import '../../domain/models/live_moderation.dart';

/// Resultado de uma ação de moderação (a UI só distingue estas três).
enum ModerationResult { ok, forbidden, failed }

final liveModerationServiceProvider = Provider<LiveModerationService>((ref) {
  return LiveModerationService(ref.watch(liveDioProvider));
});

/// REST da moderação da live (silenciar, fixar, moderadores).
/// Nunca lança: devolve [ModerationResult] (403 = sem permissão).
class LiveModerationService {
  LiveModerationService(this._dio);

  final Dio _dio;

  /// Estado inicial da sala: `{pin, slow_mode_s}` (null em falha).
  Future<({ChatPin? pin, int slowModeS})?> getRoomState(String roomId) async {
    try {
      final r = await _dio.get('/live/rooms/$roomId');
      final data = r.data;
      final room = data is Map ? (data['data'] ?? data) : null;
      if (room is! Map) return null;
      return (
        pin: ChatPin.tryParse(room['pinned']),
        slowModeS: parseSlowModeInterval({'slow_mode_s': room['slow_mode_s']}) ?? 0,
      );
    } catch (e) {
      debugPrint('LiveModerationService.getRoomState: $e');
      return null;
    }
  }

  /// [minutes]: 5, 60 ou `null` (até o fim da live).
  Future<ModerationResult> mute(
    String roomId,
    String userId, {
    int? minutes,
  }) => _run(
    () => _dio.post(
      '/live/rooms/$roomId/mute',
      data: {'user_id': userId, 'minutes': minutes},
    ),
  );

  Future<ModerationResult> unmute(String roomId, String userId) =>
      _run(() => _dio.delete('/live/rooms/$roomId/mute/$userId'));

  Future<ModerationResult> pin(
    String roomId, {
    required String text,
    String? messageId,
    String? authorName,
    String? authorId,
  }) => _run(
    () => _dio.post(
      '/live/rooms/$roomId/pin',
      data: {
        'text': text.length > 300 ? text.substring(0, 300) : text,
        'message_id': ?messageId,
        if (authorName != null && authorName.isNotEmpty)
          'author_name': authorName,
        if (authorId != null && authorId.isNotEmpty) 'author_id': authorId,
      },
    ),
  );

  Future<ModerationResult> unpin(String roomId) =>
      _run(() => _dio.delete('/live/rooms/$roomId/pin'));

  /// Moderadores do usuário logado (criador). `null` em falha.
  Future<List<LiveModerator>?> listModerators() async {
    try {
      final r = await _dio.get('/live/moderators');
      return LiveModerator.parseList(r.data);
    } catch (e) {
      debugPrint('LiveModerationService.listModerators: $e');
      return null;
    }
  }

  Future<ModerationResult> addModerator(String userId) =>
      _run(() => _dio.post('/live/moderators', data: {'user_id': userId}));

  Future<ModerationResult> removeModerator(String userId) =>
      _run(() => _dio.delete('/live/moderators/$userId'));

  Future<ModerationResult> _run(Future<Response<dynamic>> Function() call) async {
    try {
      await call();
      return ModerationResult.ok;
    } on DioException catch (e) {
      debugPrint('LiveModerationService: ${e.response?.statusCode} ${e.message}');
      return e.response?.statusCode == 403
          ? ModerationResult.forbidden
          : ModerationResult.failed;
    } catch (e) {
      debugPrint('LiveModerationService: $e');
      return ModerationResult.failed;
    }
  }
}
