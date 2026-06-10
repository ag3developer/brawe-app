import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';
import '../model/create_live_room_request_dto.dart';
import '../model/live_room_dto.dart';

part 'live_service.g.dart';

@riverpod
LiveService liveService(Ref ref) {
  return LiveService(ref.watch(liveDioProvider));
}

class LiveService {
  final Dio _dio;

  LiveService(this._dio);

  /// Normaliza chaves do payload da API antes de bater no Freezed:
  /// - `/live/feed` retorna `room_id`; `/live/rooms/:id` retorna `id`.
  /// - Mapeia `playback_url` para o nosso modelo.
  /// Esta camada nos isola de inconsistências do backend.
  Map<String, dynamic> _normalizeRoomJson(Map<String, dynamic> raw) {
    final out = Map<String, dynamic>.from(raw);
    if (out['id'] == null && out['room_id'] != null) {
      out['id'] = out['room_id'];
    }
    return out;
  }

  Future<List<LiveRoomDto>> getLiveFeed({
    String? cursor,
    int limit = 10,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};
    if (cursor != null) {
      queryParams['cursor'] = cursor;
    }

    final response = await _dio.get('/live/feed', queryParameters: queryParams);

    // The API might return an object like { "rooms": [...] } or a list directly.
    final data = response.data;
    if (data is Map<String, dynamic>) {
      // Check for common collection keys
      final List<dynamic>? list =
          (data['rooms'] ?? data['items'] ?? data['data'] ?? data['lives'])
              as List<dynamic>?;

      if (list != null) {
        return list
            .map((e) => LiveRoomDto.fromJson(_normalizeRoomJson(e as Map<String, dynamic>)))
            .toList();
      }
    } else if (data is List) {
      return data
          .map((e) => LiveRoomDto.fromJson(_normalizeRoomJson(e as Map<String, dynamic>)))
          .toList();
    }

    return [];
  }

  Future<List<LiveRoomDto>> getRooms({
    String? status,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) queryParams['status'] = status;
    if (category != null) queryParams['category'] = category;

    final response = await _dio.get(
      '/live/rooms',
      queryParameters: queryParams,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final List<dynamic>? list =
          (data['rooms'] ?? data['items'] ?? data['data'] ?? data['lives'])
              as List<dynamic>?;

      if (list != null) {
        return list
            .map((e) => LiveRoomDto.fromJson(_normalizeRoomJson(e as Map<String, dynamic>)))
            .toList();
      }
    } else if (data is List) {
      return data
          .map((e) => LiveRoomDto.fromJson(_normalizeRoomJson(e as Map<String, dynamic>)))
          .toList();
    }

    return [];
  }

  Future<LiveRoomDto?> getRoom(String idOrSlug) async {
    final response = await _dio.get('/live/rooms/$idOrSlug');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      // The API returns { "success": true, "data": { ...room... } }
      final roomData = data['data'] ?? data;
      if (roomData is Map<String, dynamic>) {
        return LiveRoomDto.fromJson(_normalizeRoomJson(roomData));
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> createLiveRoom(
    CreateLiveRoomRequestDto request,
  ) async {
    final response = await _dio.post('/live/rooms', data: request.toJson());
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> startLive(String roomId) async {
    final response = await _dio.post('/live/rooms/$roomId/start');
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> endLive(String roomId) async {
    final response = await _dio.post('/live/rooms/$roomId/end');
    return _toMap(response.data);
  }

  Future<Map<String, dynamic>> pauseLive(String roomId) async {
    // API does not have a dedicated pause endpoint — local-only state.
    // Fire-and-forget update via end/start is not applicable here; just return success.
    return {'status': 'ok'};
  }

  Future<Map<String, dynamic>> resumeLive(String roomId) async {
    // API does not have a dedicated resume endpoint — local-only state.
    return {'status': 'ok'};
  }

  Future<Map<String, dynamic>> sendHeartbeat(String roomId) async {
    // API does not have a heartbeat endpoint — no-op graceful fallback.
    return {'status': 'ok'};
  }

  /// Compartilha a live com seguidores via DM (endpoint não disponível — no-op).
  Future<Map<String, dynamic>> shareLive(
    String roomId, {
    required List<String> userIds,
    String? note,
  }) async {
    return {'status': 'ok'};
  }

  /// Warm-up: avisa seguidores que a live vai comecar (endpoint não disponível — no-op).
  Future<Map<String, dynamic>> announceLive(
    String roomId, {
    int? secondsUntilLive,
  }) async {
    return {'status': 'ok'};
  }

  Future<Map<String, dynamic>> getStreamStatus(String roomId) async {
    // Endpoint not available — return room info as fallback
    final room = await getRoom(roomId);
    return {'status': room?.status ?? 'unknown'};
  }

  Future<Map<String, dynamic>> updateThumbnail({
    required String roomId,
    required String thumbnailUrl,
  }) async {
    // Endpoint not available — no-op
    return {'status': 'ok'};
  }

  Future<Map<String, dynamic>> regenerateStreamKey(String roomId) async {
    // Endpoint not available — no-op
    return {'status': 'ok'};
  }

  Future<void> likeLive(String roomId) async {
    await _dio.post('/media/$roomId/like', data: {'reaction_type': 'like'});
  }

  Future<void> unlikeLive(String roomId) async {
    await _dio.delete('/media/$roomId/like');
  }

  Future<Map<String, dynamic>> sendGift({
    required String roomId,
    required String giftId,
    required String receiverId,
    int quantity = 1,
    String? battleId,
    String? idempotencyKey,
  }) async {
    final response = await _dio.post(
      '/live/gifts/send-gift',
      data: {
        'room_id': roomId,
        'gift_id': giftId,
        'receiver_id': receiverId,
        'quantity': quantity,
        if (battleId != null) 'battle_id': battleId,
      },
      options: idempotencyKey != null
          ? Options(headers: {'Idempotency-Key': idempotencyKey})
          : null,
    );
    return _toMap(response.data);
  }

  /// 🏆 Top gifters de uma sala (dados persistidos no backend).
  /// Retorna lista de `{ user_id, display_name, avatar_url, total_coins, gift_count }`.
  Future<List<Map<String, dynamic>>> getTopGifters(
    String roomId, {
    int limit = 10,
  }) async {
    final response = await _dio.get(
      '/live/gifts/top-gifters/$roomId',
      queryParameters: {'limit': limit},
    );
    final data = response.data;
    // API retorna { "top_gifters": [...] } ou lista direta.
    final raw = data is Map ? (data['top_gifters'] ?? data['data'] ?? data) : data;
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return {};
  }
}
