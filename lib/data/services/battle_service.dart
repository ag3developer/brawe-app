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

  /// Check if the current streamer is eligible to start a battle.
  /// Returns the full eligibility response: { data: { battle: { eligible, reason, ... } } }
  Future<Map<String, dynamic>> checkEligibility() async {
    final response = await _dio.get('/live/battle/eligibility');
    return _toMap(response.data);
  }

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

  /// 🔄 Pedir revanche de uma batalha encerrada.
  /// Cria um novo convite (status=PENDING) entre os mesmos 2 streamers,
  /// com a mesma duração da batalha anterior. Pode ser chamado por A ou B.
  /// Backend: POST /live/battle/{id}/rematch
  Future<Map<String, dynamic>> requestRematch(String battleId) async {
    final response = await _dio.post('/live/battle/$battleId/rematch');
    return _toMap(response.data);
  }

  /// 🛑 Encerrar batalha antes do tempo (botão "Sair da batalha").
  /// Funciona para batalhas ACTIVE (encerra agora) e PENDING/ACCEPTED (cancela).
  /// Só os 2 participantes podem chamar.
  /// Backend: POST /live/battle/{id}/end
  /// O backend responde 202 imediatamente e processa em background — o resultado
  /// real chega via socket `connect:battle:ended`. Por isso usamos receiveTimeout
  /// curto (8s): se demorar mais, tratamos como fire-and-forget no HUD.
  Future<Map<String, dynamic>> endBattleEarly(String battleId) async {
    final response = await _dio.post(
      '/live/battle/$battleId/end',
      options: Options(receiveTimeout: const Duration(seconds: 8)),
    );
    return _toMap(response.data);
  }

  /// Get live scores — usa o endpoint Redis de baixa latência.
  /// Fallback para o endpoint DB se o Redis não tiver dados ainda.
  Future<Map<String, dynamic>> getLiveScores(String battleId) async {
    // Tenta primeiro o endpoint Redis (baixa latência, tem time_remaining_seconds)
    try {
      final response = await _dio.get('/live/battle/$battleId/live-scores');
      final envelope = _toMap(response.data);
      final data = (envelope['data'] is Map)
          ? Map<String, dynamic>.from(envelope['data'] as Map)
          : envelope;
      // O endpoint Redis já retorna os campos no formato esperado pelo BattleViewModel:
      // score_a, score_b, gifts_count_a, gifts_count_b, time_remaining_seconds, status
      return data;
    } catch (_) {
      // Fallback: endpoint DB (batalha recém-criada ainda não tem dados no Redis)
      return getBattle(battleId);
    }
  }

  /// Get full battle info.
  Future<Map<String, dynamic>> getBattle(String battleId) async {
    final response = await _dio.get('/live/battle/$battleId');
    return _toMap(response.data);
  }

  /// Check if there is an active battle for a given room (mid-battle detection).
  /// Returns a map with `battle_id` on success; throws DioException(404) if none.
  Future<Map<String, dynamic>> getActiveBattleForRoom(String roomId) async {
    final response = await _dio.get('/live/battle/active', queryParameters: {'room_id': roomId});
    final envelope = _toMap(response.data);
    return (envelope['data'] is Map)
        ? Map<String, dynamic>.from(envelope['data'] as Map)
        : envelope;
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
