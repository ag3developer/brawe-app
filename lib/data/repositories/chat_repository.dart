import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/models/conversation.dart';
import '../../domain/models/failure.dart';
import '../services/messages_service.dart';
import '../services/socket_service.dart';
import '../services/storage_service.dart';

part 'chat_repository.g.dart';

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  final socketService = ref.watch(socketServiceProvider);
  final messagesService = ref.watch(messagesServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  final repository = ChatRepository(
    socketService: socketService,
    messagesService: messagesService,
    storageService: storageService,
  );
  ref.onDispose(repository.dispose);
  return repository;
}

class ChatRepository {
  ChatRepository({
    required SocketService socketService,
    required MessagesService messagesService,
    required StorageService storageService,
  })  : _socketService = socketService,
        _messagesService = messagesService,
        _storageService = storageService;

  final SocketService _socketService;
  final MessagesService _messagesService;
  final StorageService _storageService;

  final Map<String, StreamController<ChatMessage>> _messageControllers = {};
  final Map<String, StreamController<bool>> _typingControllers = {};
  final StreamController<ChatMessage> _notificationController =
      StreamController<ChatMessage>.broadcast();
  final Map<String, StreamController<String>> _burnControllers = {};
  final Map<String, StreamController<MessageReactionUpdate>> _reactionControllers = {};

  bool _handlersRegistered = false;
  void Function(dynamic)? _onNewMessage;
  void Function(dynamic)? _onUserTyping;
  void Function(dynamic)? _onUserStopTyping;
  void Function(dynamic)? _onMessageNotification;
  void Function(dynamic)? _onMessageBurned;
  void Function(dynamic)? _onMessageReaction;

  // ────────────────────── lifecycle ──────────────────────

  Future<void> connect() async {
    await _socketService.connect();
    _registerHandlers();
  }

  void _registerHandlers() {
    if (_handlersRegistered) return;
    _handlersRegistered = true;

    _onNewMessage = (data) {
      final payload = _asMap(data);
      if (payload == null) return;
      final conversationId = payload['conversation_id']?.toString();
      if (conversationId == null || conversationId.isEmpty) return;
      final message =
          ChatMessage.fromApi(payload, fallbackConversationId: conversationId);
      final controller = _messageControllers[conversationId];
      if (controller != null && !controller.isClosed) {
        controller.add(message);
      }
    };
    _socketService.on(AppConstants.eventNewMessage, _onNewMessage!);

    _onUserTyping = (data) {
      final conversationId = _asMap(data)?['conversation_id']?.toString();
      if (conversationId == null) return;
      _typingControllers[conversationId]?.add(true);
    };
    _socketService.on(AppConstants.eventUserTyping, _onUserTyping!);

    _onUserStopTyping = (data) {
      final conversationId = _asMap(data)?['conversation_id']?.toString();
      if (conversationId == null) return;
      _typingControllers[conversationId]?.add(false);
    };
    _socketService.on(AppConstants.eventUserStopTyping, _onUserStopTyping!);

    _onMessageNotification = (data) {
      final payload = _asMap(data);
      if (payload == null) return;
      final conversationId = payload['conversation_id']?.toString() ?? '';
      _notificationController.add(
        ChatMessage(
          id: 'notif-${DateTime.now().microsecondsSinceEpoch}',
          conversationId: conversationId,
          senderId: payload['sender_id']?.toString() ?? '',
          content: payload['preview']?.toString() ?? '',
          timestamp: DateTime.now(),
        ),
      );
    };
    _socketService.on(
      AppConstants.eventMessageNotification,
      _onMessageNotification!,
    );

    _onMessageBurned = (data) {
      final payload = _asMap(data);
      if (payload == null) return;
      final conversationId = payload['conversation_id']?.toString();
      final messageId = payload['message_id']?.toString();
      if (conversationId == null || messageId == null) return;
      final controller = _burnControllers[conversationId];
      if (controller != null && !controller.isClosed) {
        controller.add(messageId);
      }
    };
    _socketService.on(AppConstants.eventMessageBurned, _onMessageBurned!);

    _onMessageReaction = (data) {
      final payload = _asMap(data);
      if (payload == null) return;
      final conversationId = payload['conversation_id']?.toString();
      final messageId = payload['id']?.toString();
      if (conversationId == null || messageId == null) return;
      final rawReactions = payload['reactions'];
      final reactions = <String, List<String>>{};
      if (rawReactions is Map) {
        rawReactions.forEach((k, v) {
          if (v is List) {
            reactions[k.toString()] =
                v.map((e) => e.toString()).toList(growable: false);
          }
        });
      }
      final controller = _reactionControllers[conversationId];
      if (controller != null && !controller.isClosed) {
        controller.add(MessageReactionUpdate(
          messageId: messageId,
          reactions: reactions,
        ));
      }
    };
    _socketService.on(AppConstants.eventMessageReaction, _onMessageReaction!);
  }

  void dispose() {
    _socketService.off(AppConstants.eventNewMessage, _onNewMessage);
    _socketService.off(AppConstants.eventUserTyping, _onUserTyping);
    _socketService.off(AppConstants.eventUserStopTyping, _onUserStopTyping);
    _socketService.off(
      AppConstants.eventMessageNotification,
      _onMessageNotification,
    );
    _socketService.off(AppConstants.eventMessageBurned, _onMessageBurned);
    _socketService.off(AppConstants.eventMessageReaction, _onMessageReaction);

    for (final c in _messageControllers.values) {
      c.close();
    }
    for (final c in _typingControllers.values) {
      c.close();
    }
    for (final c in _burnControllers.values) {
      c.close();
    }
    for (final c in _reactionControllers.values) {
      c.close();
    }
    _messageControllers.clear();
    _typingControllers.clear();
    _burnControllers.clear();
    _notificationController.close();
    _handlersRegistered = false;
  }

  // ────────────────────── streams ──────────────────────

  Stream<ChatMessage> watchMessages(String conversationId) {
    final controller = _messageControllers.putIfAbsent(
      conversationId,
      () => StreamController<ChatMessage>.broadcast(),
    );
    return controller.stream;
  }

  Stream<bool> watchTyping(String conversationId) {
    final controller = _typingControllers.putIfAbsent(
      conversationId,
      () => StreamController<bool>.broadcast(),
    );
    return controller.stream;
  }

  Stream<String> watchBurns(String conversationId) {
    final controller = _burnControllers.putIfAbsent(
      conversationId,
      () => StreamController<String>.broadcast(),
    );
    return controller.stream;
  }

  /// Notificações de novas mensagens em outras conversas (para refresh da lista).
  Stream<ChatMessage> watchNotifications() => _notificationController.stream;

  // ────────────────────── room ──────────────────────

  void joinConversation(String conversationId) {
    _socketService.joinConversation(conversationId);
  }

  void leaveConversation(String conversationId) {
    _socketService.leaveConversation(conversationId);
  }

  // ────────────────────── REST ──────────────────────

  Future<List<Conversation>> listConversations({
    int page = 1,
    int limit = AppConstants.conversationsPageLimit,
    bool archived = false,
  }) async {
    try {
      return await _messagesService.listConversations(
        page: page,
        limit: limit,
        archived: archived,
      );
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<List<ChatMessage>> fetchMessages(
    String conversationId, {
    int page = 1,
    int limit = AppConstants.chatPageLimit,
  }) async {
    try {
      return await _messagesService.getMessages(
        conversationId,
        page: page,
        limit: limit,
      );
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String message,
    String? replyToMessageId,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      throw const Failure.validation('Message cannot be empty.');
    }
    try {
      return await _messagesService.sendMessage(
        conversationId: conversationId,
        content: trimmed,
        replyToMessageId: replyToMessageId,
      );
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<Map<String, List<String>>> reactToMessage({
    required String messageId,
    required String emoji,
  }) async {
    try {
      return await _messagesService.reactMessage(
        messageId: messageId,
        emoji: emoji,
      );
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<void> markMessagesRead({required String conversationId}) async {
    try {
      await _messagesService.markAsRead(conversationId);
    } on DioException catch (e) {
      debugPrint('markMessagesRead failed: $e');
      throw _toFailure(e);
    }
  }

  Future<int> getUnreadCount() async {
    try {
      return await _messagesService.getUnreadCount();
    } on DioException catch (e) {
      debugPrint('getUnreadCount failed: $e');
      return 0;
    }
  }

  Future<String> startConversation({required String participantId}) async {
    try {
      return await _messagesService.startConversation(participantId);
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<({String conversationId, String otherUserId})>
      getOrCreateConversationByUser(String slug) async {
    try {
      return await _messagesService.getOrCreateByUser(slug);
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<Map<String, UserPresence>> getPresence(List<String> userIds) async {
    try {
      return await _messagesService.getPresence(userIds);
    } on DioException catch (_) {
      return const {};
    }
  }

  Future<ChatMessage> uploadImage({
    required String conversationId,
    required String filePath,
    bool viewOnce = false,
  }) async {
    try {
      return await _messagesService.uploadImage(
        conversationId: conversationId,
        filePath: filePath,
        viewOnce: viewOnce,
      );
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<void> burnMessage(String messageId) async {
    try {
      await _messagesService.burnMessage(messageId);
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _messagesService.deleteMessage(messageId);
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Stream<MessageReactionUpdate> reactionStream(String conversationId) {
    final controller = _reactionControllers.putIfAbsent(
      conversationId,
      () => StreamController<MessageReactionUpdate>.broadcast(),
    );
    return controller.stream;
  }

  Future<void> archiveConversation(String conversationId) async {
    try {
      await _messagesService.archiveConversation(conversationId);
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<void> unarchiveConversation(String conversationId) async {
    try {
      await _messagesService.unarchiveConversation(conversationId);
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await _messagesService.deleteConversation(conversationId);
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  // ────────────────────── socket-only ──────────────────────

  void sendTypingStart({required String conversationId}) {
    _socketService.sendTypingStart(conversationId: conversationId);
  }

  void sendTypingStop({required String conversationId}) {
    _socketService.sendTypingStop(conversationId: conversationId);
  }

  Future<String?> getCurrentUserId() async {
    final user = await _storageService.getUser();
    return user?.id;
  }

  // ────────────────────── helpers ──────────────────────

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  Failure _toFailure(DioException e) {
    final status = e.response?.statusCode;
    if (status == null) return const Failure.network();
    if (status == 401 || status == 403) {
      return const Failure.unauthorized();
    }
    if (status >= 400 && status < 500) {
      final detail = e.response?.data is Map
          ? e.response?.data['detail']?.toString()
          : null;
      return Failure.validation(detail);
    }
    if (status >= 500) return const Failure.server();
    return const Failure.unknown();
  }
}

class MessageReactionUpdate {
  const MessageReactionUpdate({
    required this.messageId,
    required this.reactions,
  });
  final String messageId;
  final Map<String, List<String>> reactions;
}
