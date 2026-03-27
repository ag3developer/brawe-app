import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../domain/models/conversation.dart';
import '../../../domain/models/failure.dart';
import '../../../domain/models/user.dart';

part 'chat_detail_view_model.g.dart';

class ChatDetailState {
  const ChatDetailState({
    this.messages = const <ChatMessage>[],
    this.isTyping = false,
    this.isSending = false,
    this.errorMessage,
  });

  final List<ChatMessage> messages;
  final bool isTyping;
  final bool isSending;
  final String? errorMessage;

  ChatDetailState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    bool? isSending,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ChatDetailState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      isSending: isSending ?? this.isSending,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class ChatDetailViewModel extends _$ChatDetailViewModel {
  late final String _conversationId;
  StreamSubscription<ChatMessage>? _messagesSubscription;
  StreamSubscription<bool>? _typingSubscription;
  Timer? _typingStopTimer;

  @override
  ChatDetailState build(String conversationId) {
    _conversationId = conversationId;

    ref.onDispose(() {
      _messagesSubscription?.cancel();
      _typingSubscription?.cancel();
      _typingStopTimer?.cancel();
    });

    _initialize(conversationId);

    return const ChatDetailState();
  }

  Future<void> _initialize(String conversationId) async {
    try {
      await ref.read(chatRepositoryProvider).connect();

      _messagesSubscription = ref
          .read(chatRepositoryProvider)
          .watchMessages(conversationId)
          .listen(_handleIncomingMessage);

      _typingSubscription = ref
          .read(chatRepositoryProvider)
          .watchTyping(conversationId)
          .listen(_handleTypingIndicator);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to connect to chat',
      );
    }
  }

  void _handleIncomingMessage(ChatMessage message) {
    // Don't add duplicate messages
    if (state.messages.any((m) => m.id == message.id)) {
      return;
    }

    state = state.copyWith(
      messages: [...state.messages, message],
      clearErrorMessage: true,
    );
  }

  void _handleTypingIndicator(bool isTyping) {
    _typingStopTimer?.cancel();
    state = state.copyWith(isTyping: isTyping);

    if (isTyping) {
      // Auto-reset typing after 5 seconds
      _typingStopTimer = Timer(const Duration(seconds: 5), () {
        if (ref.mounted) {
          state = state.copyWith(isTyping: false);
        }
      });
    }
  }

  Future<void> sendMessage(String content) async {
    final trimmedMessage = content.trim();
    if (trimmedMessage.isEmpty) {
      return;
    }

    final optimisticMessage = _buildOptimisticMessage(trimmedMessage);
    _appendMessage(optimisticMessage);
    state = state.copyWith(isSending: true, clearErrorMessage: true);

    try {
      await ref.read(chatRepositoryProvider).sendMessage(
        conversationId: _conversationId,
        message: trimmedMessage,
      );
      _markMessageAsSent(optimisticMessage.id);
      state = state.copyWith(isSending: false);
    } on Failure catch (failure) {
      _removeMessage(optimisticMessage.id);
      state = state.copyWith(
        isSending: false,
        errorMessage: failure.toDisplayMessage(),
      );
    } catch (_) {
      _removeMessage(optimisticMessage.id);
      state = state.copyWith(
        isSending: false,
        errorMessage: const Failure.unknown().toDisplayMessage(),
      );
    }
  }

  void onTyping() {
    ref.read(chatRepositoryProvider).sendTypingStart(
      conversationId: _conversationId,
    );
  }

  void onTypingStopped() {
    ref.read(chatRepositoryProvider).sendTypingStop(
      conversationId: _conversationId,
    );
  }

  void markAsRead() {
    ref.read(chatRepositoryProvider).markMessagesRead(
      conversationId: _conversationId,
    );
  }

  ChatMessage _buildOptimisticMessage(String content) {
    final authState = ref.read(authStateProvider);
    final currentUser = authState is AsyncData<User?> ? authState.value : null;
    final timestamp = DateTime.now();
    return ChatMessage(
      id: 'local-${timestamp.microsecondsSinceEpoch}',
      conversationId: _conversationId,
      senderId: currentUser?.id ?? 'current-user',
      content: content,
      timestamp: timestamp,
      isPending: true,
    );
  }

  void _appendMessage(ChatMessage message) {
    state = state.copyWith(
      messages: [...state.messages, message],
      clearErrorMessage: true,
    );
  }

  void _markMessageAsSent(String messageId) {
    state = state.copyWith(
      messages: state.messages
          .map(
            (message) => message.id == messageId
                ? message.copyWith(isPending: false)
                : message,
          )
          .toList(growable: false),
    );
  }

  void _removeMessage(String messageId) {
    state = state.copyWith(
      messages: state.messages
          .where((message) => message.id != messageId)
          .toList(growable: false),
    );
  }
}
