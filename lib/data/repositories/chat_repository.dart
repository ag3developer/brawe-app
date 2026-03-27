import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/conversation.dart';
import '../../domain/models/failure.dart';
import '../services/socket_service.dart';
import '../services/storage_service.dart';

part 'chat_repository.g.dart';

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  final socketService = ref.watch(socketServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  final repository = ChatRepository(socketService, storageService);
  ref.onDispose(repository.dispose);
  return repository;
}

class ChatRepository {
  final SocketService _socketService;
  final StorageService _storageService;
  final Map<String, StreamController<ChatMessage>> _messageControllers = {};
  final Map<String, StreamController<bool>> _typingControllers = {};
  final StreamController<List<Conversation>> _conversationsController =
      StreamController<List<Conversation>>.broadcast();
  bool _handlersRegistered = false;
  void Function(dynamic)? _onDmReceived;
  void Function(dynamic)? _onUserTyping;
  void Function(dynamic)? _onConversationUpdated;

  ChatRepository(this._socketService, this._storageService);

  Future<void> connect() async {
    await _socketService.connect();
    _registerHandlers();
  }

  void _registerHandlers() {
    if (_handlersRegistered) return;
    _handlersRegistered = true;

    _onDmReceived = (data) {
      debugPrint('ChatRepository: Received dm_received: $data');
      final message = _parseDmMessage(data);
      if (message == null) return;

      final payload = _asMap(data);
      final conversationId = payload?['conversation_id']?.toString();

      if (conversationId != null) {
        final controller = _messageControllers[conversationId];
        if (controller != null && !controller.isClosed) {
          controller.add(message);
        }
      }
    };
    _socketService.on(AppConstants.eventDmReceived, _onDmReceived!);

    _onUserTyping = (data) {
      debugPrint('ChatRepository: Received user_typing: $data');
      final payload = _asMap(data);
      final conversationId = payload?['conversation_id']?.toString();
      if (conversationId == null) return;

      final controller = _typingControllers[conversationId];
      if (controller != null && !controller.isClosed) {
        controller.add(true);
      }
    };
    _socketService.on(AppConstants.eventUserTyping, _onUserTyping!);

    _onConversationUpdated = (data) {
      debugPrint('ChatRepository: Received conversation_updated: $data');
      final conversation = _parseConversation(data);
      if (conversation == null) return;

      _conversationsController.add(_updateConversationInList(conversation));
    };
    _socketService.on(AppConstants.eventConversationUpdated, _onConversationUpdated!);
  }

  void dispose() {
    _socketService.off(AppConstants.eventDmReceived, _onDmReceived);
    _socketService.off(AppConstants.eventUserTyping, _onUserTyping);
    _socketService.off(AppConstants.eventConversationUpdated, _onConversationUpdated);

    for (final controller in _messageControllers.values) {
      controller.close();
    }
    for (final controller in _typingControllers.values) {
      controller.close();
    }
    _messageControllers.clear();
    _typingControllers.clear();
    _handlersRegistered = false;
  }

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

  Stream<List<Conversation>> watchConversations() {
    return _conversationsController.stream;
  }

  Future<void> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      throw const Failure.validation('Message cannot be empty.');
    }

    if (!_socketService.isConnected) {
      throw const Failure.network();
    }

    _socketService.sendDm(
      conversationId: conversationId,
      message: trimmedMessage,
    );
  }

  Future<void> startConversation({required String participantId}) async {
    if (!_socketService.isConnected) {
      throw const Failure.network();
    }

    _socketService.startConversation(participantId: participantId);
  }

  void sendTypingStart({required String conversationId}) {
    _socketService.sendTypingStart(conversationId: conversationId);
  }

  void sendTypingStop({required String conversationId}) {
    _socketService.sendTypingStop(conversationId: conversationId);
  }

  void markMessagesRead({required String conversationId}) {
    _socketService.markMessagesRead(conversationId: conversationId);
  }

  Future<String?> getCurrentUserId() async {
    final user = await _storageService.getUser();
    return user?.id;
  }

  ChatMessage? _parseDmMessage(dynamic data) {
    final payload = _asMap(data);
    if (payload == null) return null;

    final message = payload['message']?.toString().trim();
    if (message == null || message.isEmpty) return null;

    final timestampValue = payload['timestamp']?.toString();
    final timestamp =
        DateTime.tryParse(timestampValue ?? '')?.toLocal() ?? DateTime.now();

    return ChatMessage(
      id: payload['id']?.toString() ??
          timestamp.microsecondsSinceEpoch.toString(),
      conversationId: payload['conversation_id']?.toString() ?? '',
      senderId: payload['sender_id']?.toString() ??
                payload['user_id']?.toString() ?? '',
      content: message,
      timestamp: timestamp,
      isRead: payload['is_read'] == true,
    );
  }

  Conversation? _parseConversation(dynamic data) {
    final payload = _asMap(data);
    if (payload == null) return null;

    final id = payload['id']?.toString() ?? payload['conversation_id']?.toString();
    if (id == null) return null;

    final participantId = payload['participant_id']?.toString() ?? '';
    final participantName = payload['participant_name']?.toString() ??
                           payload['sender_name']?.toString() ?? 'User';
    final participantAvatar = payload['participant_avatar']?.toString() ??
                              payload['sender_avatar']?.toString();

    ChatMessage? lastMessage;
    if (payload['last_message'] != null) {
      lastMessage = _parseDmMessage(payload['last_message']);
    }

    final updatedAtValue = payload['updated_at']?.toString();
    final updatedAt = DateTime.tryParse(updatedAtValue ?? '')?.toLocal() ?? DateTime.now();

    return Conversation(
      id: id,
      participantId: participantId,
      participantName: participantName,
      participantAvatarUrl: participantAvatar,
      lastMessage: lastMessage,
      unreadCount: int.tryParse(payload['unread_count']?.toString() ?? '0') ?? 0,
      updatedAt: updatedAt,
    );
  }

  List<Conversation> _updateConversationInList(Conversation updated) {
    return [updated];
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
}
