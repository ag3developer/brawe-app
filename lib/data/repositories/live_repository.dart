import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/live_room.dart';
import '../services/live_service.dart';
import '../model/create_live_room_request_dto.dart';
import '../model/live_room_dto.dart';
import '../../domain/models/failure.dart';
import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart';

part 'live_repository.g.dart';

@riverpod
LiveRepository liveRepository(Ref ref) {
  return LiveRepository(ref.watch(liveServiceProvider));
}

class LiveRepository {
  final LiveService _liveService;

  LiveRepository(this._liveService);

  Future<List<LiveRoom>> getLiveFeed({String? cursor, int limit = 10}) async {
    try {
      final dtos = await _liveService.getLiveFeed(cursor: cursor, limit: limit);
      debugPrint('LiveRepository: getLiveFeed returned ${dtos.length} items');
      return dtos.map((dto) => dto.toDomain()).toList();
    } on DioException catch (e) {
      debugPrint('LiveRepository: getLiveFeed DioException: ${e.message}');
      throw const Failure.network();
    } catch (e) {
      debugPrint('LiveRepository: getLiveFeed Error: $e');
      throw const Failure.unknown();
    }
  }

  Future<List<LiveRoom>> getRooms({
    String? status,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final dtos = await _liveService.getRooms(
        status: status,
        category: category,
        page: page,
        limit: limit,
      );
      debugPrint('LiveRepository: getRooms returned ${dtos.length} items');
      return dtos.map((dto) => dto.toDomain()).toList();
    } on DioException catch (e) {
      debugPrint('LiveRepository: getRooms DioException: ${e.message}');
      throw const Failure.network();
    } catch (e) {
      debugPrint('LiveRepository: getRooms Error: $e');
      throw const Failure.unknown();
    }
  }

  Future<LiveRoom> initiateLive(CreateLiveRoomRequestDto request) async {
    try {
      final createResponse = await _liveService.createLiveRoom(request);
      final createdRoom = _extractLiveRoom(
        createResponse,
        fallbackTitle: request.title,
      );

      if (createdRoom == null) {
        throw const Failure.server();
      }

      final startResponse = await _liveService.startLive(createdRoom.id);
      final startedRoom =
          _extractLiveRoom(startResponse, fallbackTitle: createdRoom.title) ??
          createdRoom.copyWith(
            status: 'live',
            streamUrl:
                _readString(
                  startResponse['stream_url'] ??
                      startResponse['hls_url'] ??
                      startResponse['playback_url'],
                ) ??
                createdRoom.streamUrl,
          );

      return startedRoom.toDomain();
    } on Failure {
      rethrow;
    } on DioException catch (e) {
      debugPrint('LiveRepository: initiateLive DioException: ${e.message}');
      throw _mapFailure(e);
    } catch (e) {
      debugPrint('LiveRepository: initiateLive Error: $e');
      throw const Failure.unknown();
    }
  }

  Failure _mapFailure(DioException exception) {
    final statusCode = exception.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return const Failure.unauthorized();
    }

    if (statusCode == 422) {
      return const Failure.validation(
        'Please review your live room details and try again.',
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return const Failure.server();
    }

    return const Failure.network();
  }

  LiveRoomDto? _extractLiveRoom(
    Map<String, dynamic> payload, {
    String? fallbackTitle,
  }) {
    final candidates = <dynamic>[
      payload,
      payload['room'],
      payload['live'],
      payload['data'],
      payload['result'],
      payload['payload'],
    ];

    for (final candidate in candidates) {
      if (candidate is! Map) {
        continue;
      }

      final room = _toLiveRoomDto(
        Map<String, dynamic>.from(candidate),
        fallbackTitle: fallbackTitle,
      );
      if (room != null) {
        return room;
      }
    }

    final fallbackId = _readString(
      payload['room_id'] ?? payload['live_id'] ?? payload['id'],
    );
    if (fallbackId == null) {
      return null;
    }

    return LiveRoomDto(
      id: fallbackId,
      title: fallbackTitle ?? 'Untitled Live',
      status: _readString(payload['status']) ?? 'scheduled',
      liveType: 'solo',
      isPrivate: false,
      streamerName: 'You',
      streamUrl: _readString(
        payload['stream_url'] ?? payload['hls_url'] ?? payload['playback_url'],
      ),
    );
  }

  LiveRoomDto? _toLiveRoomDto(
    Map<String, dynamic> source, {
    String? fallbackTitle,
  }) {
    final id = _readString(
      source['id'] ?? source['room_id'] ?? source['live_id'] ?? source['slug'],
    );
    if (id == null) {
      return null;
    }

    final payload = Map<String, dynamic>.from(source);
    payload['id'] = id;
    payload['title'] = _readString(payload['title']) ?? fallbackTitle;
    payload['streamer_name'] = _readString(payload['streamer_name']) ?? 'You';
    payload['status'] = _readString(payload['status']) ?? 'scheduled';

    return LiveRoomDto.fromJson(payload);
  }

  String? _readString(dynamic value) {
    if (value == null) {
      return null;
    }

    final normalized = value.toString().trim();
    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}
