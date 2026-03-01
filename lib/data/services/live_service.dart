import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';
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
    // Assuming standard pagination structure based on JSON schema
    if (response.data is Map<String, dynamic> &&
        response.data.containsKey('rooms')) {
      final feedResponse = LiveFeedResponseDto.fromJson(response.data);
      return feedResponse.rooms;
    } else if (response.data is List) {
      final list = response.data as List;
      return list
          .map((e) => LiveRoomDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Fallback if data structure is unexpected
    return [];
  }
}
