import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/live_comment.dart';
import '../../domain/models/live_room.dart';
import '../../domain/models/live_gift.dart';
import '../services/live_service.dart';
import '../model/create_live_room_request_dto.dart';
import '../model/live_room_dto.dart';
import '../../domain/models/failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/socket_service.dart';

part 'live_repository.g.dart';

@Riverpod(keepAlive: true)
LiveRepository liveRepository(Ref ref) {
  final repository = LiveRepository(
    ref.watch(liveServiceProvider),
    ref.watch(socketServiceProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
}

class LiveRepository {
  final LiveService _liveService;
  final SocketService? _socketService;
  final Map<String, StreamController<LiveComment>> _commentControllers = {};
  final Map<String, StreamController<int>> _viewerCountControllers = {};
  final Map<String, StreamController<LiveGift>> _giftControllers = {};
  final Set<String> _connectedRooms = {};
  final Map<String, int> _roomConnectionLeases = {};
  bool _socketHandlersRegistered = false;
  void Function(dynamic)? _onNewMessage;
  void Function(dynamic)? _onViewerCount;
  void Function(dynamic)? _onViewerJoined;
  void Function(dynamic)? _onViewerLeft;
  void Function(dynamic)? _onNewGift;

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

  Future<void> endLive(String roomId) async {
    try {
      await _liveService.endLive(roomId);
    } on DioException catch (e) {
      debugPrint('LiveRepository: endLive DioException: ${e.message}');
      throw _mapFailure(e);
    } catch (e) {
      debugPrint('LiveRepository: endLive Error: $e');
      throw const Failure.unknown();
    }
  }

  Future<void> pauseLive(String roomId) async {
    try {
      await _liveService.pauseLive(roomId);
    } on DioException catch (e) {
      debugPrint('LiveRepository: pauseLive DioException: ${e.message}');
      throw _mapFailure(e);
    } catch (e) {
      debugPrint('LiveRepository: pauseLive Error: $e');
      throw const Failure.unknown();
    }
  }

  Future<void> resumeLive(String roomId) async {
    try {
      await _liveService.resumeLive(roomId);
    } on DioException catch (e) {
      debugPrint('LiveRepository: resumeLive DioException: ${e.message}');
      throw _mapFailure(e);
    } catch (e) {
      debugPrint('LiveRepository: resumeLive Error: $e');
      throw const Failure.unknown();
    }
  }

  Future<Map<String, dynamic>> sendHeartbeat(String roomId) async {
    try {
      return await _liveService.sendHeartbeat(roomId);
    } on DioException catch (e) {
      debugPrint('LiveRepository: sendHeartbeat DioException: ${e.message}');
      throw _mapFailure(e);
    } catch (e) {
      debugPrint('LiveRepository: sendHeartbeat Error: $e');
      throw const Failure.unknown();
    }
  }

  Future<Map<String, dynamic>> getStreamStatus(String roomId) async {
    try {
      return await _liveService.getStreamStatus(roomId);
    } on DioException catch (e) {
      debugPrint('LiveRepository: getStreamStatus DioException: ${e.message}');
      throw _mapFailure(e);
    } catch (e) {
      debugPrint('LiveRepository: getStreamStatus Error: $e');
      throw const Failure.unknown();
    }
  }

  Future<Map<String, dynamic>> updateThumbnail({
    required String roomId,
    required String thumbnailUrl,
  }) async {
    try {
      return await _liveService.updateThumbnail(
        roomId: roomId,
        thumbnailUrl: thumbnailUrl,
      );
    } on DioException catch (e) {
      debugPrint('LiveRepository: updateThumbnail DioException: ${e.message}');
      throw _mapFailure(e);
    } catch (e) {
      debugPrint('LiveRepository: updateThumbnail Error: $e');
      throw const Failure.unknown();
    }
  }

  Future<Map<String, dynamic>> regenerateStreamKey(String roomId) async {
    try {
      return await _liveService.regenerateStreamKey(roomId);
    } on DioException catch (e) {
      debugPrint(
        'LiveRepository: regenerateStreamKey DioException: ${e.message}',
      );
      throw _mapFailure(e);
    } catch (e) {
      debugPrint('LiveRepository: regenerateStreamKey Error: $e');
      throw const Failure.unknown();
    }
  }

  Future<void> connectToRoom(String roomId) async {
    await _ensureConnectedToRoom(roomId, trackLease: true);
  }

  Future<void> _ensureConnectedToRoom(
    String roomId, {
    required bool trackLease,
  }) async {
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
      if (trackLease) {
        _roomConnectionLeases.update(
          roomId,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
      getLiveViewers(roomId);
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('LiveRepository: connectToRoom Error: $e');
      throw const Failure.network();
    }
  }

  void dispose() {
    _socketService?.off(AppConstants.eventNewMessage, _onNewMessage);
    _socketService?.off(AppConstants.eventViewerCount, _onViewerCount);
    _socketService?.off('viewer_joined', _onViewerJoined);
    _socketService?.off('viewer_left', _onViewerLeft);
    _socketService?.off(AppConstants.eventNewGift, _onNewGift);

    for (final controller in _commentControllers.values) {
      controller.close();
    }
    for (final controller in _viewerCountControllers.values) {
      controller.close();
    }
    for (final controller in _giftControllers.values) {
      controller.close();
    }

    _commentControllers.clear();
    _viewerCountControllers.clear();
    _giftControllers.clear();
    _connectedRooms.clear();
    _roomConnectionLeases.clear();
    _socketHandlersRegistered = false;
  }

  void disconnectFromRoom(String roomId) {
    final remainingLeases = (_roomConnectionLeases[roomId] ?? 0) - 1;
    if (remainingLeases > 0) {
      _roomConnectionLeases[roomId] = remainingLeases;
      return;
    }

    _roomConnectionLeases.remove(roomId);
    if (!_connectedRooms.remove(roomId)) {
      return;
    }

    _socketService?.leaveRoom(roomId);

    final commentsController = _commentControllers.remove(roomId);
    commentsController?.close();

    final viewerCountController = _viewerCountControllers.remove(roomId);
    viewerCountController?.close();

    final giftController = _giftControllers.remove(roomId);
    giftController?.close();
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

  Future<void> toggleLike(String roomId, bool isLiked) async {
    try {
      if (isLiked) {
        await _liveService.unlikeLive(roomId);
      } else {
        await _liveService.likeLive(roomId);
      }
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  void getLiveViewers(String roomId) {
    _socketService?.emit(AppConstants.eventRequestViewers, {'room_id': roomId});
  }

  void updateViewerCount(String roomId, int count) {
    _dispatchToIntControllers(_viewerCountControllers, count, roomId: roomId);
  }

  Stream<LiveGift> watchGifts(String roomId) {
    final controller = _giftControllers.putIfAbsent(
      roomId,
      () => StreamController<LiveGift>.broadcast(),
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

    await _ensureConnectedToRoom(roomId, trackLease: false);
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

    _onNewMessage = (data) {
      debugPrint(
        'LiveRepository: Received event ${AppConstants.eventNewMessage}: $data',
      );
      final comment = _parseLiveComment(data);
      if (comment == null) {
        debugPrint('LiveRepository: Failed to parse comment from $data');
        return;
      }

      // If the message has a room_id, we should only add it to that room's controller
      final payload = _asMap(data);
      final msgRoomId = payload?['room_id']?.toString();

      _dispatchToCommentControllers(comment, roomId: msgRoomId);
    };
    _socketService.on(AppConstants.eventNewMessage, _onNewMessage!);

    _onViewerCount = (data) {
      debugPrint(
        'LiveRepository: Received event ${AppConstants.eventViewerCount}: $data',
      );
      final count = _parseViewerCount(data);
      if (count == null) return;

      final payload = _asMap(data);
      final msgRoomId = payload?['room_id']?.toString();

      _dispatchToIntControllers(
        _viewerCountControllers,
        count,
        roomId: msgRoomId,
      );
    };
    _socketService.on(AppConstants.eventViewerCount, _onViewerCount!);

    _onViewerJoined = (data) {
      debugPrint('LiveRepository: Received event viewer_joined: $data');
      final count = _parseViewerCount(data);
      if (count == null) return;

      final payload = _asMap(data);
      final msgRoomId = payload?['room_id']?.toString();

      _dispatchToIntControllers(
        _viewerCountControllers,
        count,
        roomId: msgRoomId,
      );
    };
    _socketService.on('viewer_joined', _onViewerJoined!);

    _onViewerLeft = (data) {
      debugPrint('LiveRepository: Received event viewer_left: $data');
      final count = _parseViewerCount(data);
      if (count == null) return;

      final payload = _asMap(data);
      final msgRoomId = payload?['room_id']?.toString();

      _dispatchToIntControllers(
        _viewerCountControllers,
        count,
        roomId: msgRoomId,
      );
    };
    _socketService.on('viewer_left', _onViewerLeft!);

    _onNewGift = (data) {
      debugPrint(
        'LiveRepository: Received event ${AppConstants.eventNewGift}: $data',
      );
      final gift = _parseLiveGift(data);
      if (gift == null) return;

      final payload = _asMap(data);
      final msgRoomId = payload?['room_id']?.toString();

      _dispatchToGiftControllers(gift, roomId: msgRoomId);
    };
    _socketService.on(AppConstants.eventNewGift, _onNewGift!);
  }

  void _dispatchToCommentControllers(LiveComment comment, {String? roomId}) {
    _dispatchToControllers(_commentControllers, comment, roomId: roomId);
  }

  void _dispatchToGiftControllers(LiveGift gift, {String? roomId}) {
    _dispatchToControllers(_giftControllers, gift, roomId: roomId);
  }

  void _dispatchToIntControllers(
    Map<String, StreamController<int>> controllers,
    int value, {
    String? roomId,
  }) {
    _dispatchToControllers(controllers, value, roomId: roomId);
  }

  void _dispatchToControllers<T>(
    Map<String, StreamController<T>> controllers,
    T value, {
    String? roomId,
  }) {
    final targetRoomId = roomId?.trim();
    if (targetRoomId != null && targetRoomId.isNotEmpty) {
      final targetController = controllers[targetRoomId];
      if (targetController != null && !targetController.isClosed) {
        targetController.add(value);
        return;
      }
    }

    final activeControllers = controllers.entries
        .where((entry) => !entry.value.isClosed)
        .toList(growable: false);
    if (activeControllers.isNotEmpty) {
      for (final entry in activeControllers) {
        entry.value.add(value);
      }
      return;
    }

    for (final connectedRoomId in _connectedRooms) {
      final controller = controllers[connectedRoomId];
      if (controller == null || controller.isClosed) {
        continue;
      }
      controller.add(value);
    }
  }

  LiveComment? _parseLiveComment(dynamic data) {
    final payload = _asMap(data);
    if (payload == null) return null;

    final message = payload['message']?.toString().trim();
    if (message == null || message.isEmpty) return null;

    final timestampValue = payload['timestamp']?.toString();
    final timestamp =
        DateTime.tryParse(timestampValue ?? '')?.toLocal() ?? DateTime.now();

    return LiveComment(
      id:
          payload['id']?.toString() ??
          timestamp.microsecondsSinceEpoch.toString(),
      userId: payload['user_id']?.toString() ?? '',
      userName:
          payload['sender_name']?.toString() ??
          payload['name']?.toString() ??
          'Viewer',
      avatarUrl:
          payload['sender_avatar']?.toString() ??
          payload['avatar_url']?.toString(),
      message: message,
      timestamp: timestamp,
    );
  }

  int? _parseViewerCount(dynamic data) {
    final payload = _asMap(data);
    if (payload == null) {
      return null;
    }

    final rawCount = payload['count'] ?? payload['viewer_count'];
    if (rawCount is int) {
      return rawCount;
    }

    if (rawCount is num) {
      return rawCount.toInt();
    }

    return int.tryParse(rawCount?.toString() ?? '');
  }

  LiveGift? _parseLiveGift(dynamic data) {
    final payload = _asMap(data);
    if (payload == null) return null;

    final giftId = payload['gift_id']?.toString();
    if (giftId == null) return null;

    final timestampValue = payload['timestamp']?.toString();
    final timestamp =
        DateTime.tryParse(timestampValue ?? '')?.toLocal() ?? DateTime.now();

    return LiveGift(
      id:
          payload['transaction_id']?.toString() ??
          payload['id']?.toString() ??
          timestamp.microsecondsSinceEpoch.toString(),
      senderId: payload['user_id']?.toString() ?? '',
      senderName: payload['sender_name']?.toString() ?? 'Viewer',
      senderAvatarUrl: payload['sender_avatar']?.toString(),
      giftId: giftId,
      giftName: payload['gift_name']?.toString() ?? 'Gift',
      giftIconUrl: payload['animation_url']?.toString(),
      quantity: int.tryParse(payload['quantity']?.toString() ?? '1') ?? 1,
      timestamp: timestamp,
    );
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
        rootPayload['status'] ?? AppConstants.statusScheduled;
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
