import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/live_comment.dart';
import '../../domain/models/live_room.dart';
import '../services/live_service.dart';
import '../model/create_live_room_request_dto.dart';
import '../model/live_room_dto.dart';
import '../../domain/models/failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/socket_service.dart';

part 'live_repository.g.dart';

@riverpod
LiveRepository liveRepository(Ref ref) {
  return LiveRepository(
    ref.watch(liveServiceProvider),
    ref.watch(socketServiceProvider),
  );
}

class LiveRepository {
  final LiveService _liveService;
  final SocketService? _socketService;
  final Map<String, StreamController<LiveComment>> _commentControllers = {};
  final Map<String, StreamController<int>> _viewerCountControllers = {};
  final Set<String> _connectedRooms = {};
  bool _socketHandlersRegistered = false;

  LiveRepository(this._liveService, [SocketService? socketService])
    : _socketService = socketService;

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

  Future<void> connectToRoom(String roomId) async {
    final socketService = _socketService;
    if (socketService == null) {
      throw const Failure.network();
    }

    try {
      await socketService.connect();
      if (!socketService.isConnected) {
        throw const Failure.network();
      }

      _registerSocketHandlers();
      if (_connectedRooms.add(roomId)) {
        socketService.joinRoom(roomId);
      }
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('LiveRepository: connectToRoom Error: $e');
      throw const Failure.network();
    }
  }

  void disconnectFromRoom(String roomId) {
    if (!_connectedRooms.remove(roomId)) {
      return;
    }

    _socketService?.leaveRoom(roomId);

    final commentsController = _commentControllers.remove(roomId);
    commentsController?.close();

    final viewerCountController = _viewerCountControllers.remove(roomId);
    viewerCountController?.close();
  }

  Stream<LiveComment> watchComments(String roomId) {
    final controller = _commentControllers.putIfAbsent(
      roomId,
      () => StreamController<LiveComment>.broadcast(),
    );
    return controller.stream;
  }

  Stream<int> watchViewerCount(String roomId) {
    final controller = _viewerCountControllers.putIfAbsent(
      roomId,
      () => StreamController<int>.broadcast(),
    );
    return controller.stream;
  }

  Future<void> sendComment({
    required String roomId,
    required String message,
  }) async {
    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      throw const Failure.validation('Comment cannot be empty.');
    }

    final socketService = _socketService;
    if (socketService == null) {
      throw const Failure.network();
    }

    await connectToRoom(roomId);
    socketService.sendChatMessage(roomId: roomId, message: trimmedMessage);
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

  void _registerSocketHandlers() {
    if (_socketHandlersRegistered || _socketService == null) {
      return;
    }

    _socketHandlersRegistered = true;
    debugPrint('LiveRepository: Registering socket handlers');

    _socketService.on(AppConstants.eventNewMessage, (data) {
      debugPrint('LiveRepository: Received event ${AppConstants.eventNewMessage}: $data');
      final comment = _parseLiveComment(data);
      if (comment == null) {
        debugPrint('LiveRepository: Failed to parse comment from $data');
        return;
      }

      // If the message has a room_id, we should only add it to that room's controller
      final payload = _asMap(data);
      final msgRoomId = payload?['room_id']?.toString();

      if (msgRoomId != null) {
        _commentControllers[msgRoomId]?.add(comment);
      } else {
        // Fallback: send to all connected rooms if no room_id in payload
        for (final roomId in _connectedRooms) {
          _commentControllers[roomId]?.add(comment);
        }
      }
    });

    _socketService.on(AppConstants.eventViewerCount, (data) {
      debugPrint('LiveRepository: Received event ${AppConstants.eventViewerCount}: $data');
      final count = _parseViewerCount(data);
      if (count == null) return;

      final payload = _asMap(data);
      final msgRoomId = payload?['room_id']?.toString();

      if (msgRoomId != null) {
        _viewerCountControllers[msgRoomId]?.add(count);
      } else {
        for (final roomId in _connectedRooms) {
          _viewerCountControllers[roomId]?.add(count);
        }
      }
    });
  }

  LiveComment? _parseLiveComment(dynamic data) {
    final payload = _asMap(data);
    if (payload == null) return null;

    final message = payload['message']?.toString().trim();
    if (message == null || message.isEmpty) return null;

    final timestampValue = payload['timestamp']?.toString();
    final timestamp =
        DateTime.tryParse(timestampValue ?? '')?.toLocal() ?? DateTime.now();

    // Map fields from both app and connect APIs
    return LiveComment(
      id: payload['id']?.toString() ??
          payload['_id']?.toString() ??
          timestamp.microsecondsSinceEpoch.toString(),
      userId: payload['user_id']?.toString() ?? payload['user']?['_id']?.toString() ?? '',
      userName: payload['name']?.toString() ??
          payload['user']?['name']?.toString() ??
          payload['username']?.toString() ??
          'Viewer',
      avatarUrl: payload['avatar_url']?.toString() ?? payload['user']?['avatar']?.toString(),
      message: message,
      timestamp: timestamp,
    );
  }

  int? _parseViewerCount(dynamic data) {
    final payload = _asMap(data);
    if (payload == null) {
      return null;
    }

    final rawCount = payload['count'];
    if (rawCount is int) {
      return rawCount;
    }

    if (rawCount is num) {
      return rawCount.toInt();
    }

    return int.tryParse(rawCount?.toString() ?? '');
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    if (data is List && data.isNotEmpty) {
      return _asMap(data.first);
    }

    return null;
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
    normalized['status'] ??=
        rootPayload['status'] ?? AppConstants.statusWaiting;
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
