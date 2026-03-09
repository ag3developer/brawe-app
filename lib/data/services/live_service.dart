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
            .map((e) => LiveRoomDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } else if (data is List) {
      return data
          .map((e) => LiveRoomDto.fromJson(e as Map<String, dynamic>))
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
            .map((e) => LiveRoomDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } else if (data is List) {
      return data
          .map((e) => LiveRoomDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
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
