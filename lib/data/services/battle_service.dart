import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';
import '../../domain/models/battle_candidate.dart';

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

  /// Regras públicas da batalha (durações permitidas e padrão).
  /// API: GET /live/battle/config → `{success, data:{durations_s, default_duration_s, ...}}`
  Future<Map<String, dynamic>> getBattleConfig() async {
    final response = await _dio.get('/live/battle/config');
    return _toMap(response.data);
  }

  /// Invite another streamer to a battle.
  /// API: POST /live/battle/invite { opponent_room_id, duration_seconds }
  Future<Map<String, dynamic>> inviteBattle({
    required String
    roomId, // kept for compatibility (not sent — JWT identifies caller)
    required String targetRoomId,
    int durationSeconds = 300,
    String? linkId,
  }) async {
    final response = await _dio.post(
      '/live/battle/invite',
      data: {
        'opponent_room_id': targetRoomId,
        'duration_seconds': durationSeconds,
        // Batalha dentro de uma conexão (§8.2).
        if (linkId != null) 'link_id': linkId,
      },
    );
    return _toMap(response.data);
  }

  /// Accept a pending battle invitation.
  Future<Map<String, dynamic>> acceptBattle(String battleId) async {
    final response = await _dio.post('/live/battle/$battleId/accept');
    return _toMap(response.data);
  }

  /// Criadores ao vivo que podem ser convidados agora (paginado).
  /// API: GET /live/battle/candidates?q=&limit=&cursor=
  /// Retorna `(items, nextCursor)`; `nextCursor == null` = fim da lista.
  Future<(List<BattleCandidate>, String?)> getCandidates({
    String? query,
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/live/battle/candidates',
      queryParameters: {
        if (query != null && query.isNotEmpty) 'q': query,
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      },
    );
    final envelope = _toMap(response.data);
    final data = envelope['data'] is Map
        ? Map<String, dynamic>.from(envelope['data'] as Map)
        : envelope;
    final items = (data['items'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => BattleCandidate.fromJson(Map<String, dynamic>.from(e)))
        .where((c) => c.roomId.isNotEmpty)
        .toList();
    final next = data['next_cursor']?.toString();
    return (items, next == null || next.isEmpty ? null : next);
  }

  /// Cancela um convite que EU enviei e ainda está pendente.
  Future<Map<String, dynamic>> cancelInvite(String battleId) async {
    final response = await _dio.post('/live/battle/$battleId/cancel');
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
  Future<Map<String, dynamic>> getLiveScores(String battleId, {String? roomId}) async {
    // Tenta primeiro o endpoint Redis (baixa latência, tem time_remaining_seconds)
    try {
      final response = await _dio.get(
        '/live/battle/$battleId/live-scores',
        queryParameters: {if (roomId != null) 'room_id': roomId},
      );
      final envelope = _toMap(response.data);
      final data = (envelope['data'] is Map)
          ? Map<String, dynamic>.from(envelope['data'] as Map)
          : envelope;
      // O endpoint Redis já retorna os campos no formato esperado pelo BattleViewModel:
      // score_a, score_b, gifts_count_a, gifts_count_b, time_remaining_seconds, status
      return data;
    } catch (_) {
      // Fallback: endpoint DB (batalha recém-criada ainda não tem dados no Redis)
      return getBattle(battleId, roomId: roomId);
    }
  }

  /// Get full battle info.
  Future<Map<String, dynamic>> getBattle(String battleId, {String? roomId}) async {
    // `room_id`: o servidor filtra pelo lado da sala (lado fechado, §9.3).
    final response = await _dio.get(
      '/live/battle/$battleId',
      queryParameters: {if (roomId != null) 'room_id': roomId},
    );
    return _toMap(response.data);
  }

  /// Check if there is an active battle for a given room (mid-battle detection).
  /// Returns a map with `battle_id` on success; throws DioException(404) if none.
  Future<Map<String, dynamic>> getActiveBattleForRoom(String roomId) async {
    final response = await _dio.get(
      '/live/battle/active',
      queryParameters: {'room_id': roomId},
    );
    final envelope = _toMap(response.data);
    return (envelope['data'] is Map)
        ? Map<String, dynamic>.from(envelope['data'] as Map)
        : envelope;
  }

  /// Credenciais do LiveKit para o criador entrar na sala `battle-{id}`.
  /// Backend: `GET /live/battle/{id}/rtc` (409 fora de accepted/countdown/
  /// active; 503 com o tempo real desligado).
  Future<BattleRtcCredentials> getRtc(String battleId) async {
    final response = await _dio.get(
      '/live/battle/$battleId/rtc',
      options: Options(receiveTimeout: const Duration(seconds: 6)),
    );
    final envelope = _toMap(response.data);
    final data = envelope['data'] is Map
        ? Map<String, dynamic>.from(envelope['data'] as Map)
        : envelope;
    return BattleRtcCredentials.fromJson(data);
  }

  /// Silencia/reativa o adversário NO MEU lado.
  /// Backend: `POST /live/battle/{id}/mute {muted}` → `{muted:{a,b}}`.
  Future<({bool a, bool b})?> setMute(String battleId, bool muted) async {
    final response = await _dio.post(
      '/live/battle/$battleId/mute',
      data: {'muted': muted},
    );
    final envelope = _toMap(response.data);
    final data = envelope['data'] is Map
        ? Map<String, dynamic>.from(envelope['data'] as Map)
        : envelope;
    final m = data['muted'];
    if (m is Map) return (a: m['a'] == true, b: m['b'] == true);
    return null;
  }

  /// Classifica um erro de batalha (sem expor texto cru do servidor/exceção).
  static BattleError classifyError(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final data = error.response?.data;
      String text = '';
      String code = '';
      int? retryAfter;
      if (data is Map) {
        final detail = data['detail'];
        if (detail is String) text = detail;
        if (detail is Map) {
          text = '${detail['message'] ?? ''}';
          code = '${detail['code'] ?? detail['error'] ?? ''}';
          retryAfter = (detail['retry_after'] as num?)?.toInt();
        }
        code = code.isEmpty ? '${data['code'] ?? data['error_code'] ?? ''}' : code;
        retryAfter ??= (data['retry_after'] as num?)?.toInt();
      }
      retryAfter ??= int.tryParse(
        error.response?.headers.value('retry-after') ?? '',
      );
      final lower = '$code $text'.toLowerCase();
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return const BattleError(BattleErrorKind.network);
      }
      if (status == 429) {
        return BattleError(BattleErrorKind.cooldown, retryAfter: retryAfter);
      }
      if (lower.contains('block') || lower.contains('bloque')) {
        return const BattleError(BattleErrorKind.blocked);
      }
      if (lower.contains('eleg') || lower.contains('eligib')) {
        return const BattleError(BattleErrorKind.notEligible);
      }
      if (lower.contains('expir') || status == 410) {
        return const BattleError(BattleErrorKind.expired);
      }
      if (lower.contains('respondid') || lower.contains('already')) {
        return const BattleError(BattleErrorKind.answered);
      }
      if (status == 403) return const BattleError(BattleErrorKind.blocked);
      if (status == 409) return const BattleError(BattleErrorKind.busy);
    }
    return const BattleError(BattleErrorKind.generic);
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}

enum BattleErrorKind {
  network,
  cooldown,
  blocked,
  notEligible,
  expired,
  answered,
  busy,
  generic,
}

class BattleError {
  const BattleError(this.kind, {this.retryAfter});
  final BattleErrorKind kind;

  /// Segundos até poder convidar de novo (429).
  final int? retryAfter;
}

/// Resposta de `GET /live/battle/{id}/rtc`.
class BattleRtcCredentials {
  const BattleRtcCredentials({
    required this.url,
    required this.token,
    required this.room,
    required this.side,
  });

  final String url;
  final String token;
  final String room;
  final String side;

  factory BattleRtcCredentials.fromJson(Map<String, dynamic> json) {
    return BattleRtcCredentials(
      url: json['url']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      room: json['room']?.toString() ?? '',
      side: json['side']?.toString() ?? 'a',
    );
  }

  bool get isValid => url.isNotEmpty && token.isNotEmpty;
}
