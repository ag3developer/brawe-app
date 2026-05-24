import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';

part 'battle_service.g.dart';

@riverpod
BattleService battleService(Ref ref) {
  return BattleService(ref.watch(liveDioProvider));
}

class BattleService {
  final Dio _dio;

  BattleService(this._dio);

  /// Invite another streamer to a battle.
  /// API: POST /live/battle/invite { opponent_room_id, duration_seconds }
  Future<Map<String, dynamic>> inviteBattle({
    required String roomId,       // kept for compatibility (not sent — JWT identifies caller)
    required String targetRoomId,
    int durationSeconds = 300,
  }) async {
    final response = await _dio.post(
      '/live/battle/invite',
      data: {
        'opponent_room_id': targetRoomId,
        'duration_seconds': durationSeconds,
      },
    );
    return _toMap(response.data);
  }

  /// Accept a pending battle invitation.
  Future<Map<String, dynamic>> acceptBattle(String battleId) async {
    final response = await _dio.post('/live/battle/$battleId/accept');
    return _toMap(response.data);
  }

  /// Decline a pending battle invitation.
  Future<Map<String, dynamic>> declineBattle(String battleId) async {
    final response = await _dio.post('/live/battle/$battleId/decline');
    return _toMap(response.data);
  }

  /// Get live scores — fetched from battle info endpoint (no dedicated scores endpoint).
  Future<Map<String, dynamic>> getLiveScores(String battleId) async {
    final response = await _dio.get('/live/battle/$battleId');
    final data = _toMap(response.data);
    // Extract scores sub-object if present, otherwise return full response
    return (data['scores'] is Map)
        ? Map<String, dynamic>.from(data['scores'] as Map)
        : data;
  }

  /// Get full battle info.
  Future<Map<String, dynamic>> getBattle(String battleId) async {
    final response = await _dio.get('/live/battle/$battleId');
    return _toMap(response.data);
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
