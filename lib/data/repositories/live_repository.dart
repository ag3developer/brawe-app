import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/live_comment.dart';
import '../../domain/models/user_award.dart';
import '../../domain/models/live_room.dart';
import '../../domain/models/live_gift.dart';
import '../../domain/models/live_viewer_event.dart';
import '../../domain/models/live_competition_event.dart';
import '../../domain/models/live_goal.dart';
import '../../domain/models/live_event.dart';
import '../../domain/models/live_room_event.dart';
import '../../domain/models/live_reaction_event.dart';
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
  final Map<String, StreamController<int>> _likeCountControllers = {};
  final Map<String, StreamController<int>> _commentCountControllers = {};
  final Map<String, StreamController<LiveGift>> _giftControllers = {};
  final Map<String, StreamController<LiveViewerEvent>> _viewerEventControllers =
      {};
  final Map<String, StreamController<LiveReactionEvent>> _reactionControllers =
      {};
  final Map<String, StreamController<double>> _giftTotalControllers = {};
  // 🏆 Competição de presentes (gifter_ranking / top_gifter_changed /
  // gifter_overtaken) + aviso de reconexão do socket.
  final Map<String, StreamController<LiveCompetitionEvent>>
  _competitionControllers = {};
  final StreamController<void> _reconnectController =
      StreamController<void>.broadcast();

  /// 📰 Faixa de notícia: presentes grandes de QUALQUER live (evento global
  /// `global_gift_ticker`, sem filtro de sala).
  final StreamController<Map<String, dynamic>> _globalTickerController =
      StreamController<Map<String, dynamic>>.broadcast();
  bool _globalTickerRegistered = false;

  Stream<Map<String, dynamic>> watchGlobalGiftTicker() => _globalTickerController.stream;
  final Map<String, void Function(dynamic)> _competitionHandlers = {};
  VoidCallback? _competitionReconnectCb;
  final Map<String, StreamController<LiveRoomEvent>> _roomEventControllers =
      {};
  final Map<String, void Function(dynamic)> _roomEventHandlers = {};
  final Set<String> _connectedRooms = {};
  final Map<String, int> _roomConnectionLeases = {};
  bool _socketHandlersRegistered = false;
  void Function(dynamic)? _onNewMessage;
  void Function(dynamic)? _onViewerCount;
  void Function(dynamic)? _onViewerJoined;
  void Function(dynamic)? _onViewerLeft;
  void Function(dynamic)? _onNewGift;
  void Function(dynamic)? _onLiveReaction;
  void Function(dynamic)? _onLikeCount;
  void Function(dynamic)? _onCommentCount;
  void Function(dynamic)? _onGiftCountUpdate;

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
    debugPrint(
      'LiveRepository: 🔍 getRoom("$idOrSlug") — stack: ${StackTrace.current.toString().split("\n").take(5).join(" | ")}',
    );
    try {
      final dto = await _liveService.getRoom(idOrSlug);
      debugPrint(
        'LiveRepository: ✅ getRoom("$idOrSlug") → ${dto != null ? "found" : "null"}',
      );
      return dto?.toDomain();
    } on DioException catch (e) {
      debugPrint(
        'LiveRepository: ❌ getRoom("$idOrSlug") DioException status=${e.response?.statusCode} msg=${e.message}',
      );
      throw _mapFailure(e);
    } catch (e) {
      debugPrint('LiveRepository: ❌ getRoom("$idOrSlug") Error: $e');
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

  /// Encerra a live e retorna o resumo final (duração, picos de audiência,
  /// presentes recebidos, etc.) devolvido pelo backend em `data`.
  /// Retorna um Map vazio se o backend não devolver `data` (nunca lança
  /// nesse caso específico — só lança em falha real de rede/servidor).
  Future<Map<String, dynamic>> endLive(String roomId) async {
    try {
      final response = await _liveService.endLive(roomId);
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
      return <String, dynamic>{};
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

  /// Compartilha a live com seguidores via DM. Retorna `sent` (quantos chegaram).
  Future<int> shareLiveToUsers(
    String roomId, {
    required List<String> userIds,
    String? note,
  }) async {
    try {
      final data = await _liveService.shareLive(
        roomId,
        userIds: userIds,
        note: note,
      );
      final payload = data['data'] as Map?;
      return (payload?['sent'] as int?) ?? 0;
    } on DioException catch (e) {
      debugPrint('LiveRepository: shareLiveToUsers DioException: ${e.message}');
      throw _mapFailure(e);
    } catch (e) {
      debugPrint('LiveRepository: shareLiveToUsers Error: $e');
      throw const Failure.unknown();
    }
  }

  /// Aviso de "esquentando" a live. Backend dispara push aos seguidores.
  /// Se o endpoint nao existir ainda no servidor, falha silenciosamente
  /// (warm-up vira no-op para nao bloquear o fluxo).
  Future<bool> announceLive(String roomId, {int? secondsUntilLive}) async {
    try {
      await _liveService.announceLive(
        roomId,
        secondsUntilLive: secondsUntilLive,
      );
      return true;
    } on DioException catch (e) {
      debugPrint('LiveRepository: announceLive DioException: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('LiveRepository: announceLive Error: $e');
      return false;
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
    _socketService?.off(AppConstants.eventLiveChat, _onNewMessage);
    _socketService?.off(AppConstants.eventViewerCount, _onViewerCount);
    _socketService?.off('viewer_joined', _onViewerJoined);
    _socketService?.off('viewer_left', _onViewerLeft);
    _socketService?.off(AppConstants.eventNewGift, _onNewGift);
    _socketService?.off('gift_count_update', _onGiftCountUpdate);
    _socketService?.off(AppConstants.eventLiveReaction, _onLiveReaction);
    _socketService?.off(AppConstants.eventLikeCountUpdate, _onLikeCount);
    _socketService?.off(AppConstants.eventCommentCountUpdate, _onCommentCount);
    _unregisterCompetitionHandlers();
    for (final controller in _competitionControllers.values) {
      controller.close();
    }
    _competitionControllers.clear();
    _reconnectController.close();
    _roomEventHandlers.forEach((e, h) => _socketService?.off(e, h));
    _roomEventHandlers.clear();
    for (final c in _roomEventControllers.values) {
      c.close();
    }
    _roomEventControllers.clear();

    for (final controller in _commentControllers.values) {
      controller.close();
    }
    for (final controller in _viewerCountControllers.values) {
      controller.close();
    }
    for (final controller in _likeCountControllers.values) {
      controller.close();
    }
    for (final controller in _commentCountControllers.values) {
      controller.close();
    }
    for (final controller in _giftControllers.values) {
      controller.close();
    }

    _commentControllers.clear();
    _viewerCountControllers.clear();
    _likeCountControllers.clear();
    _commentCountControllers.clear();
    _giftControllers.clear();
    for (final controller in _reactionControllers.values) {
      controller.close();
    }
    _reactionControllers.clear();
    for (final controller in _giftTotalControllers.values) {
      controller.close();
    }
    _giftTotalControllers.clear();
    _connectedRooms.clear();
    _roomConnectionLeases.clear();
    _socketHandlersRegistered = false;
    _globalTickerRegistered = false;
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

    final likeCountController = _likeCountControllers.remove(roomId);
    likeCountController?.close();

    final commentCountController = _commentCountControllers.remove(roomId);
    commentCountController?.close();

    final giftController = _giftControllers.remove(roomId);
    giftController?.close();

    final viewerEventController = _viewerEventControllers.remove(roomId);
    viewerEventController?.close();

    final reactionController = _reactionControllers.remove(roomId);
    reactionController?.close();

    final giftTotalController = _giftTotalControllers.remove(roomId);
    giftTotalController?.close();

    _competitionControllers.remove(roomId)?.close();

    _roomEventControllers.remove(roomId)?.close();
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

  Stream<int> watchLikeCount(String roomId) {
    final controller = _likeCountControllers.putIfAbsent(
      roomId,
      () => StreamController<int>.broadcast(),
    );
    return controller.stream;
  }

  Stream<int> watchCommentCount(String roomId) {
    final controller = _commentCountControllers.putIfAbsent(
      roomId,
      () => StreamController<int>.broadcast(),
    );
    return controller.stream;
  }

  /// 🎯 Salva as metas da live (até 3; lista vazia remove). Só o criador.
  Future<List<LiveGoal>> setLiveGoals(String roomId, List<LiveGoalDraft> goals) async {
    try {
      final res = await _liveService.setGoals(roomId, goals.map((g) => g.toJson()).toList());
      final data = res['data'];
      return LiveGoal.listFrom(data is Map ? data['goals'] : null);
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  /// 🎯 Define (ou limpa, com `goalPoints == null`) a meta da live. Host only.
  Future<void> setLiveGoal(
    String roomId, {
    int? goalPoints,
    String? goalTitle,
  }) async {
    try {
      await _liveService.setGoal(
        roomId,
        goalPoints: goalPoints,
        goalTitle: goalTitle,
      );
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  /// 👀 Sinaliza que o usuário ficou tempo suficiente na *preview* da live
  /// no For You (≥5s). Hook fire-and-forget que o backend usa como sinal
  /// fraco de interesse para o ranking. Falhas são silenciosas.
  Future<void> signalPreviewInterest(String roomId) async {
    try {
      await _liveService.sendHeartbeat(roomId);
    } catch (_) {
      // Sem efeito colateral visível ao usuário.
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

  /// 💎 Stream do total acumulado em USDT de gifts recebidos na sala.
  /// Atualizado a cada gift enviado (evento `gift_count_update`).
  Stream<double> watchGiftTotal(String roomId) {
    final controller = _giftTotalControllers.putIfAbsent(
      roomId,
      () => StreamController<double>.broadcast(),
    );
    return controller.stream;
  }

  /// ❤️ Stream de reações (corações flutuantes) recebidas via socket.
  Stream<LiveReactionEvent> watchReactions(String roomId) {
    final controller = _reactionControllers.putIfAbsent(
      roomId,
      () => StreamController<LiveReactionEvent>.broadcast(),
    );
    return controller.stream;
  }

  /// ❤️ Envia um batch de corações (com debounce/agregação no caller).
  Future<void> sendReaction(String roomId, {int count = 1}) async {
    final socketService = _socketService;
    if (socketService == null) return;
    try {
      await _ensureConnectedToRoom(roomId, trackLease: false);
      socketService.sendLiveReaction(roomId: roomId, count: count);
    } catch (e) {
      debugPrint('LiveRepository: sendReaction Error: $e');
    }
  }

  /// 🎮 Eventos de gamificação (level-up, meta da live).
  Stream<LiveRoomEvent> watchRoomEvents(String roomId) {
    final controller = _roomEventControllers.putIfAbsent(
      roomId,
      () => StreamController<LiveRoomEvent>.broadcast(),
    );
    return controller.stream;
  }

  Stream<LiveViewerEvent> watchViewerEvents(String roomId) {
    final controller = _viewerEventControllers.putIfAbsent(
      roomId,
      () => StreamController<LiveViewerEvent>.broadcast(),
    );
    return controller.stream;
  }

  /// 🏆 Eventos da competição de presentes da sala (ranking do servidor,
  /// novo #1, ultrapassagem). Servidor antigo simplesmente nunca emite.
  Stream<LiveCompetitionEvent> watchCompetition(String roomId) {
    final controller = _competitionControllers.putIfAbsent(
      roomId,
      () => StreamController<LiveCompetitionEvent>.broadcast(),
    );
    return controller.stream;
  }

  /// 🔁 Emite a cada reconexão do socket (para refazer fetches de estado).
  Stream<void> watchReconnects() => _reconnectController.stream;

  void _registerCompetitionHandlers() {
    final socket = _socketService;
    if (socket == null) return;
    const events = {
      'gifter_ranking': LiveCompetitionEventType.ranking,
      'top_gifter_changed': LiveCompetitionEventType.topGifterChanged,
      'gifter_overtaken': LiveCompetitionEventType.overtaken,
      'liker_ranking': LiveCompetitionEventType.likerRanking,
      'like_milestone': LiveCompetitionEventType.likeMilestone,
    };
    _unregisterCompetitionHandlers(keepReconnect: true);
    events.forEach((name, type) {
      void handler(dynamic data) {
        final payload = _asMap(data);
        if (payload == null) return;
        _dispatchToControllers(
          _competitionControllers,
          LiveCompetitionEvent(type, Map<String, dynamic>.from(payload)),
          roomId: payload['room_id']?.toString(),
        );
      }

      _competitionHandlers[name] = handler;
      socket.on(name, handler);
    });
    if (_competitionReconnectCb == null) {
      _competitionReconnectCb = () {
        // O socket interno é recriado: reanexa os handlers e avisa as telas.
        _registerCompetitionHandlers();
        if (!_reconnectController.isClosed) _reconnectController.add(null);
      };
      socket.addReconnectCallback(_competitionReconnectCb!);
    }
  }

  void _unregisterCompetitionHandlers({bool keepReconnect = false}) {
    _competitionHandlers.forEach((name, h) => _socketService?.off(name, h));
    _competitionHandlers.clear();
    if (!keepReconnect && _competitionReconnectCb != null) {
      _socketService?.removeReconnectCallback(_competitionReconnectCb!);
      _competitionReconnectCb = null;
    }
  }

  /// 🏆 Top gifters completo (`data`, `total_points`, `me`). Vazio em falha.
  Future<Map<String, dynamic>> getTopGiftersFull(
    String roomId, {
    int limit = 10,
  }) async {
    try {
      return await _liveService.getTopGiftersFull(roomId, limit: limit);
    } catch (e) {
      debugPrint('LiveRepository: getTopGiftersFull Error: $e');
      return const {};
    }
  }

  /// ❤️ Top curtidores da live (`data`, `total_likes`, `unique_likers`,
  /// `me`). Vazio em falha / servidor antigo.
  Future<Map<String, dynamic>> getTopLikers(String roomId, {int limit = 10}) async {
    try {
      return await _liveService.getTopLikers(roomId, limit: limit);
    } catch (e) {
      debugPrint('LiveRepository: getTopLikers Error: $e');
      return const {};
    }
  }

  /// 🏆 Ranking de fãs do criador (`week` | `all`). Vazio em falha.
  Future<Map<String, dynamic>> getCreatorRanking(
    String streamerId, {
    String period = 'week',
    int limit = 20,
  }) async {
    try {
      return await _liveService.getCreatorRanking(
        streamerId,
        period: period,
        limit: limit,
      );
    } catch (e) {
      debugPrint('LiveRepository: getCreatorRanking Error: $e');
      return const {};
    }
  }

  /// 🎉 Ranking do evento (`data`, `me`, `prizes`). Vazio em falha.
  Future<Map<String, dynamic>> getEventRanking(String eventId, {int limit = 10}) async {
    try {
      return await _liveService.getEventRanking(eventId, limit: limit);
    } catch (e) {
      debugPrint('LiveRepository: getEventRanking Error: $e');
      return const {};
    }
  }

  /// 🎉 Evento ativo da sala. `ok=false` em falha / servidor antigo (quem
  /// chama mantém o que já tinha); `ok=true, event=null` = sem evento.
  Future<({bool ok, LiveEvent? event})> getActiveEvent(String roomId) async {
    try {
      final res = await _liveService.getActiveEvent(roomId);
      if (!res.containsKey('event')) return (ok: false, event: null);
      return (ok: true, event: LiveEvent.tryParse(res['event']));
    } catch (e) {
      debugPrint('LiveRepository: getActiveEvent Error: $e');
      return (ok: false, event: null);
    }
  }

  /// 🏆 Busca o ranking de top gifters da sala no backend.
  /// Retorna lista já mapeada para [GifterEntry] (importado de live_room_comments_view_model).
  /// Falhas são silenciosas — o ranking local via socket continua como fallback.
  Future<List<Map<String, dynamic>>> getTopGifters(
    String roomId, {
    int limit = 10,
  }) async {
    try {
      return await _liveService.getTopGifters(roomId, limit: limit);
    } catch (e) {
      debugPrint('LiveRepository: getTopGifters Error: $e');
      return [];
    }
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
    final path = exception.requestOptions.path;
    final method = exception.requestOptions.method;
    debugPrint(
      'LiveRepository: _mapFailure → $method $path → status=$statusCode body=${exception.response?.data}',
    );

    if (statusCode == 401 || statusCode == 403) {
      // 🎬 Gating de "ir ao vivo": o backend devolve 403 com um payload
      // estruturado { detail: { code, message, missing } } para casos de
      // elegibilidade (avatar, creator network, seguidores mínimos). Quando
      // há essa mensagem amigável, preservamos ela em vez de mostrar o
      // genérico "sessão expirada" — que confundiria o criador.
      final eligibilityMessage = _extractEligibilityMessage(
        exception.response?.data,
      );
      if (eligibilityMessage != null) {
        return Failure.validation(eligibilityMessage);
      }
      return const Failure.unauthorized();
    }

    if (statusCode == 404) {
      // Mapeado para validation (sem regenerar freezed) com mensagem clara.
      return const Failure.validation('Live room not found');
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

  /// Extrai a mensagem amigável de elegibilidade de um corpo de erro 403.
  ///
  /// O backend de lives devolve `{ detail: { code, missing, message } }`
  /// quando o criador é bloqueado por uma regra (avatar ausente, conta de
  /// creator inativa ou seguidores insuficientes). Retornamos a `message`
  /// pronta para exibição quando presente; caso contrário `null`, para o
  /// chamador cair no fluxo padrão de "não autorizado".
  String? _extractEligibilityMessage(dynamic data) {
    if (data is Map) {
      final detail = data['detail'];
      if (detail is Map) {
        final message = detail['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
    }
    return null;
  }

  void _registerSocketHandlers() {
    if (_socketHandlersRegistered || _socketService == null) {
      return;
    }

    _socketHandlersRegistered = true;
    debugPrint('LiveRepository: Registering socket handlers');
    _onLikeCount = (data) {
      final payload = _asMap(data);
      if (payload == null) return;
      final msgRoomId = payload['room_id']?.toString();
      final raw =
          payload['total_likes'] ?? payload['like_count'] ?? payload['count'];
      final count = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
      if (count == null) return;
      debugPrint(
        'LiveRepository: like_count_update → room=$msgRoomId count=$count',
      );
      _dispatchToIntControllers(
        _likeCountControllers,
        count,
        roomId: msgRoomId,
      );
    };
    _socketService.on(AppConstants.eventLikeCountUpdate, _onLikeCount!);
    _onCommentCount = (data) {
      final payload = _asMap(data);
      if (payload == null) return;
      final msgRoomId = payload['room_id']?.toString();
      final raw = payload['total_messages'] ?? payload['count'];
      final count = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
      if (count == null) return;
      debugPrint(
        'LiveRepository: comment_count_update → room=$msgRoomId count=$count',
      );
      _dispatchToIntControllers(
        _commentCountControllers,
        count,
        roomId: msgRoomId,
      );
    };
    _socketService.on(AppConstants.eventCommentCountUpdate, _onCommentCount!);
    _onNewMessage = (data) {
      debugPrint(
        'LiveRepository: Received event ${AppConstants.eventLiveChat}: $data',
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
    _socketService.on(AppConstants.eventLiveChat, _onNewMessage!);

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
      final payload = _asMap(data);
      final msgRoomId = payload?['room_id']?.toString();

      final count = _parseViewerCount(data);
      if (count != null) {
        _dispatchToIntControllers(
          _viewerCountControllers,
          count,
          roomId: msgRoomId,
        );
      }

      if (payload != null &&
          (payload['user_id']?.toString().isNotEmpty ?? false)) {
        final event = LiveViewerEvent.fromSocket(
          Map<String, dynamic>.from(payload),
          joined: true,
        );
        _dispatchToControllers(
          _viewerEventControllers,
          event,
          roomId: msgRoomId,
        );
      }
    };
    _socketService.on('viewer_joined', _onViewerJoined!);

    _onViewerLeft = (data) {
      debugPrint('LiveRepository: Received event viewer_left: $data');
      final payload = _asMap(data);
      final msgRoomId = payload?['room_id']?.toString();

      final count = _parseViewerCount(data);
      if (count != null) {
        _dispatchToIntControllers(
          _viewerCountControllers,
          count,
          roomId: msgRoomId,
        );
      }

      if (payload != null &&
          (payload['user_id']?.toString().isNotEmpty ?? false)) {
        final event = LiveViewerEvent.fromSocket(
          Map<String, dynamic>.from(payload),
          joined: false,
        );
        _dispatchToControllers(
          _viewerEventControllers,
          event,
          roomId: msgRoomId,
        );
      }
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

    _onGiftCountUpdate = (data) {
      final payload = _asMap(data);
      if (payload == null) return;
      final msgRoomId = payload['room_id']?.toString();
      final raw = payload['total_gifts_value'] ?? payload['total'];
      final total = raw is num
          ? raw.toDouble()
          : double.tryParse(raw?.toString() ?? '');
      if (total == null) return;
      _dispatchToControllers(_giftTotalControllers, total, roomId: msgRoomId);
    };
    _socketService.on('gift_count_update', _onGiftCountUpdate!);

    _onLiveReaction = (data) {
      final payload = _asMap(data);
      if (payload == null) return;
      final msgRoomId = payload['room_id']?.toString();
      final count = int.tryParse(payload['count']?.toString() ?? '1') ?? 1;
      if (count <= 0) return;
      // 🎯 battle_side: backend só envia quando a sala está em batalha
      // (valor 'a' ou 'b'). Em lives solo é null e o overlay cai no
      // comportamento clássico (faixa direita, cor aleatória).
      final rawSide = payload['battle_side']?.toString();
      final battleSide = (rawSide == 'a' || rawSide == 'b') ? rawSide : null;
      final event = LiveReactionEvent(
        userId: payload['user_id']?.toString() ?? '',
        count: count,
        color: payload['color']?.toString(),
        battleSide: battleSide,
        timestamp:
            DateTime.tryParse(
              payload['timestamp']?.toString() ?? '',
            )?.toLocal() ??
            DateTime.now(),
      );
      _dispatchToControllers(_reactionControllers, event, roomId: msgRoomId);
    };
    _socketService.on(AppConstants.eventLiveReaction, _onLiveReaction!);
    _registerCompetitionHandlers();
    if (!_globalTickerRegistered) {
      _globalTickerRegistered = true;
      _socketService.on('global_gift_ticker', (dynamic data) {
        final payload = _asMap(data);
        if (payload != null && !_globalTickerController.isClosed) {
          _globalTickerController.add(Map<String, dynamic>.from(payload));
        }
      });
    }

    // 🎮 Gamificação: level-up do próprio usuário, level-up público e meta.
    for (final type in const [
      LiveRoomEvent.levelUp,
      LiveRoomEvent.levelUpPublic,
      LiveRoomEvent.goalUpdate,
      LiveRoomEvent.goalsUpdate,
      LiveRoomEvent.eventUpdate,
      LiveRoomEvent.awardGranted,
      LiveRoomEvent.giftComboTier,
      LiveRoomEvent.chatError,
      LiveRoomEvent.slowMode,
      LiveRoomEvent.chatPinned,
      LiveRoomEvent.chatMuted,
    ]) {
      void handler(dynamic data) {
        final payload = _asMap(data);
        if (payload == null) return;
        _dispatchToControllers(
          _roomEventControllers,
          LiveRoomEvent(type: type, data: Map<String, dynamic>.from(payload)),
          roomId: payload['room_id']?.toString(),
        );
      }

      _roomEventHandlers[type] = handler;
      _socketService.on(type, handler);
    }
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
      }
      // Evento de OUTRA sala (sem controller aqui): descarta. Antes caía no
      // broadcast abaixo e presentes/mensagens de uma live apareciam na
      // tela de outro criador.
      return;
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

  String? _nonEmptyString(dynamic v) {
    final s = v?.toString().trim();
    return s == null || s.isEmpty || s == 'null' ? null : s;
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
      username: _nonEmptyString(payload['sender_username']),
      message: message,
      timestamp: timestamp,
      // ─── Gifter level pin (TikTok-style) ───
      gifterLevel:
          int.tryParse(payload['gifter_level']?.toString() ?? '1') ?? 1,
      gifterBadge: payload['gifter_badge']?.toString(),
      gifterLabel: payload['gifter_label']?.toString(),
      gifterColor: payload['gifter_color']?.toString(),
      gifterImageUrl: _resolveBadgeUrl(payload['gifter_image_url']?.toString()),
      award: UserAward.tryParse(payload['award']),
      isModerator: payload['is_moderator'] == true,
      isVerified: payload['is_verified'] == true,
    );
  }

  /// Resolve URL pública do badge PNG.
  /// - Se já é absoluta (http/https), retorna direto.
  /// - Se é caminho relativo (`/static/badges/lvNN.png`), prefixa com
  ///   `AppConstants.connectApiBaseUrl` para virar URL completa.
  /// - Se vazia/null, retorna null (cliente usa emoji fallback no chip).
  String? _resolveBadgeUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final v = raw.trim();
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    final base = AppConstants.connectApiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    return v.startsWith('/') ? '$base$v' : '$base/$v';
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
      giftSlug: payload['gift_slug']?.toString(),
      // 🖼 Static PNG icon for inline chat ticker / small overlay.
      // Prefer the explicit `icon_url`; fall back to `animation_url` only if
      // it looks like an image (legacy payloads).
      giftIconUrl: _pickIconUrl(payload),
      animationUrl: payload['animation_url']?.toString(),
      animationType: payload['animation_type']?.toString(),
      isFullscreen: payload['is_fullscreen'] == true,
      emoji: payload['gift_emoji']?.toString(),
      quantity: int.tryParse(payload['quantity']?.toString() ?? '1') ?? 1,
      // Pontos do ranking por unidade: `gift_points` (moedas gastas, total
      // do combo). `gift_value` é em USDT (0,1 numa rosa → arredondava 0).
      value: _unitGiftPoints(payload),
      timestamp: timestamp,
      // ─── Gifter level (TikTok-style chip) ───
      gifterLevel:
          int.tryParse(payload['gifter_level']?.toString() ?? '1') ?? 1,
      gifterBadge: payload['gifter_badge']?.toString(),
      gifterLabel: payload['gifter_label']?.toString(),
      gifterColor: payload['gifter_color']?.toString(),
      gifterImageUrl: _resolveBadgeUrl(payload['gifter_image_url']?.toString()),
      levelUpgraded: payload['level_upgraded'] == true,
      senderAward: UserAward.tryParse(payload['award']),
      eventMultiplier: _optDouble(payload['multiplier']),
      eventPoints: int.tryParse(payload['event_points']?.toString() ?? ''),
      // 🎯 Lado da batalha (vem do backend quando há `battle_id`).
      // O overlay usa pra ancorar o toast no lado certo do split-screen.
      battleSide: _parseBattleSide(payload),
      // ─── 🎯 Arquitetura profissional de exibição (4 modos) ───
      // `display_type` já vem RESOLVIDO do backend (nunca None em
      // payloads novos) — mas mantemos o parse tolerante: se ausente
      // (evento antigo/app antigo), `LiveGift.resolvedDisplayType` aplica
      // o fallback via `isFullscreen` automaticamente.
      displayType: payload['display_type']?.toString(),
      priority: int.tryParse(payload['priority']?.toString() ?? ''),
      showInChat: payload['show_in_chat'] != false, // default true
      showSender: payload['show_sender'] != false, // default true
      soundEnabled: payload['sound_enabled'] == true,
      soundUrl: payload['sound_url']?.toString(),
      animationDurationMs: int.tryParse(
        payload['animation_duration_ms']?.toString() ?? '',
      ),
      presentation: payload['presentation'] is Map
          ? Map<String, dynamic>.from(payload['presentation'] as Map)
          : null,
      comboCount: int.tryParse(payload['combo_count']?.toString() ?? ''),
      comboNextAt: int.tryParse(payload['combo_next_at']?.toString() ?? ''),
    );
  }

  static double? _optDouble(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? ''}');

  /// Extrai `battle_side` do payload de gift.
  /// Backend pode mandar como `battle_side` no nível raiz OU como
  /// `updated_side` dentro de `battle_scores` (formato antigo).
  String? _parseBattleSide(Map<String, dynamic> payload) {
    final direct = payload['battle_side']?.toString();
    if (direct == 'a' || direct == 'b') return direct;
    final scores = payload['battle_scores'];
    if (scores is Map) {
      final inner = scores['updated_side']?.toString();
      if (inner == 'a' || inner == 'b') return inner;
    }
    return null;
  }

  /// Choose a renderable static icon URL.
  /// Priority: `icon_url` → `animation_url` only when it ends with an image ext.
  String? _pickIconUrl(Map<String, dynamic> payload) {
    final icon = payload['icon_url']?.toString();
    if (icon != null && icon.trim().isNotEmpty) return icon;
    final anim = payload['animation_url']?.toString();
    if (anim == null) return null;
    final lower = anim.toLowerCase();
    if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif')) {
      return anim;
    }
    return null;
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

  static int _unitGiftPoints(Map<String, dynamic> payload) {
    final qty = int.tryParse(payload['quantity']?.toString() ?? '1') ?? 1;
    final points = num.tryParse(payload['gift_points']?.toString() ?? '');
    if (points != null) return (points / (qty < 1 ? 1 : qty)).round();
    // Servidor antigo: só USDT — converte (100 moedas = 1 USDT).
    final usdt = num.tryParse(payload['gift_value']?.toString() ?? '0') ?? 0;
    return (usdt * 100 / (qty < 1 ? 1 : qty)).round();
  }
}
