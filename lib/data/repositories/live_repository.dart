import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/app_constants.dart';
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

  Future<List<LiveRoom>> getLiveFeed({
    String? cursor,
    int limit = AppConstants.feedLimit,
  }) async {
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
    int limit = AppConstants.roomsLimit,
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

  Future<LiveRoom?> getRoom(String idOrSlug) async {
    try {
      final dto = await _liveService.getRoom(idOrSlug);
      return dto?.toDomain();
    } on DioException catch (e) {
      debugPrint('LiveRepository: getRoom DioException: ${e.message}');
      throw _mapFailure(e);
    } catch (e) {
      debugPrint('LiveRepository: getRoom Error: $e');
      throw const Failure.unknown();
    }
  }

  Future<LiveRoom> initiateLive(CreateLiveRoomRequestDto request) async {
    try {
      final createResponse = await _liveService
          .createLiveRoom(request)
          .timeout(AppConstants.liveInitiationTimeout);
      final createdRoom = _extractLiveRoomFromCreateResponse(
        createResponse,
        fallbackTitle: request.title,
      );

      if (createdRoom == null) {
        throw const Failure.server();
      }

      return createdRoom.toDomain();
    } on Failure {
      rethrow;
    } on TimeoutException {
      throw const Failure.network();
    } on DioException catch (e) {
      debugPrint('LiveRepository: initiateLive DioException: ${e.message}');
      throw _mapFailure(e);
    } catch (e) {
      debugPrint('LiveRepository: initiateLive Error: $e');
      throw const Failure.unknown();
    }
  }

  Future<void> startLive(String roomId) async {
    try {
      await _liveService.startLive(roomId);
    } on DioException catch (e) {
      debugPrint('LiveRepository: startLive DioException: ${e.message}');
      throw _mapFailure(e);
    } catch (e) {
      debugPrint('LiveRepository: startLive Error: $e');
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

  LiveRoomDto? _extractLiveRoomFromCreateResponse(
    Map<String, dynamic> payload, {
    String? fallbackTitle,
  }) {
    final root = Map<String, dynamic>.from(payload);
    final candidates = <Map<String, dynamic>>[
      root,
      ..._extractChildCandidates(root),
    ];

    for (final candidate in candidates) {
      try {
        final normalized = _normalizeCreateRoomPayload(
          candidate,
          rootPayload: root,
          fallbackTitle: fallbackTitle,
        );
        if (normalized == null) {
          continue;
        }

        return LiveRoomDto.fromJson(normalized);
      } catch (e) {
        debugPrint(
          'LiveRepository: Error parsing candidate as LiveRoomDto: $e',
        );
      }
    }

    return null;
  }

  List<Map<String, dynamic>> _extractChildCandidates(
    Map<String, dynamic> payload,
  ) {
    final candidates = <Map<String, dynamic>>[];
    final possibleContainers = <dynamic>[
      payload['room'],
      payload['live'],
      payload['data'],
    ];

    for (final container in possibleContainers) {
      if (container is! Map) {
        continue;
      }

      final map = Map<String, dynamic>.from(container);
      candidates.add(map);

      final nestedChildren = <dynamic>[map['room'], map['live'], map['data']];
      for (final child in nestedChildren) {
        if (child is Map) {
          candidates.add(Map<String, dynamic>.from(child));
        }
      }
    }

    return candidates;
  }

  Map<String, dynamic>? _normalizeCreateRoomPayload(
    Map<String, dynamic> candidate, {
    required Map<String, dynamic> rootPayload,
    String? fallbackTitle,
  }) {
    final normalized = Map<String, dynamic>.from(candidate);

    normalized['id'] ??=
        normalized['room_id'] ?? rootPayload['id'] ?? rootPayload['room_id'];
    normalized['title'] ??=
        fallbackTitle ?? rootPayload['title'] ?? rootPayload['name'];
    normalized['status'] ??= rootPayload['status'] ?? AppConstants.statusWaiting;
    normalized['playback_url'] ??= rootPayload['playback_url'];
    normalized['thumbnail_url'] ??= rootPayload['thumbnail_url'];
    normalized['host'] ??= rootPayload['host'];

    normalized['stream_config'] ??= _mergeStreamConfig(
      primary: normalized['stream_config'],
      secondary: rootPayload['stream_config'],
      tertiary: _buildStreamConfigFromPayload(rootPayload),
      quaternary: _buildStreamConfigFromPayload(normalized),
    );

    if (normalized['id'] == null) {
      return null;
    }

    return normalized;
  }

  Map<String, dynamic>? _buildStreamConfigFromPayload(
    Map<String, dynamic> payload,
  ) {
    final rtmpUrl = payload['rtmp_url'] ?? payload['ingest_url'];
    final streamKey = payload['stream_key'];
    final playbackId = payload['playback_id'];
    final playbackUrl = payload['playback_url'] ?? payload['stream_url'];

    if (rtmpUrl == null &&
        streamKey == null &&
        playbackId == null &&
        playbackUrl == null) {
      return null;
    }

    final streamConfig = <String, dynamic>{
      'rtmp_url': rtmpUrl,
      'stream_key': streamKey,
      'playback_id': playbackId,
      'playback_url': playbackUrl,
    };
    streamConfig.removeWhere((key, value) => value == null);
    return streamConfig;
  }

  Map<String, dynamic>? _mergeStreamConfig({
    dynamic primary,
    dynamic secondary,
    Map<String, dynamic>? tertiary,
    Map<String, dynamic>? quaternary,
  }) {
    final merged = <String, dynamic>{};

    void addConfig(dynamic config) {
      if (config is Map) {
        merged.addAll(Map<String, dynamic>.from(config));
      }
    }

    addConfig(primary);
    addConfig(secondary);
    addConfig(tertiary);
    addConfig(quaternary);

    return merged.isEmpty ? null : merged;
  }
}
