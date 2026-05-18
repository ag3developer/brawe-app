import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../domain/models/conversation.dart';
import '../../../domain/models/failure.dart';
import '../../../domain/models/user.dart';

part 'chat_detail_view_model.g.dart';

class ChatDetailState {
  const ChatDetailState({
    this.messages = const <ChatMessage>[],
    this.isTyping = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.isSending = false,
    this.errorMessage,
  });

  final List<ChatMessage> messages;
  final bool isTyping;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isSending;
  final String? errorMessage;

  ChatDetailState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isSending,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ChatDetailState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
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
  StreamSubscription<String>? _burnSubscription;
  StreamSubscription<MessageReactionUpdate>? _reactionSubscription;
  Timer? _typingStopTimer;
  int _currentPage = 1;

  @override
  ChatDetailState build(String conversationId) {
    _conversationId = conversationId;

    ref.onDispose(() {
      _messagesSubscription?.cancel();
      _typingSubscription?.cancel();
      _burnSubscription?.cancel();
      _reactionSubscription?.cancel();
      _typingStopTimer?.cancel();
      try {
        ref.read(chatRepositoryProvider).leaveConversation(conversationId);
      } catch (_) {}
    });

    _initialize(conversationId);

    return const ChatDetailState(isLoading: true);
  }

  Future<void> _initialize(String conversationId) async {
    final repo = ref.read(chatRepositoryProvider);

    try {
      await repo.connect();
      repo.joinConversation(conversationId);
    } catch (e) {
      debugPrint('ChatDetailViewModel: socket connect failed: $e');
    }

    _messagesSubscription =
        repo.watchMessages(conversationId).listen(_handleIncomingMessage);
    _typingSubscription =
        repo.watchTyping(conversationId).listen(_handleTypingIndicator);
    _burnSubscription =
        repo.watchBurns(conversationId).listen(_handleBurnEvent);
    _reactionSubscription =
        repo.reactionStream(conversationId).listen(_handleReactionUpdate);

    await _loadInitial();

    try {
      await repo.markMessagesRead(conversationId: conversationId);
    } catch (_) {}
  }

  Future<void> _loadInitial() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final history = await ref
          .read(chatRepositoryProvider)
          .fetchMessages(_conversationId, page: 1);
      _currentPage = 1;
      state = state.copyWith(
        messages: history,
        isLoading: false,
        hasMore: history.length >= AppConstants.chatPageLimit,
        clearErrorMessage: true,
      );
    } on Failure catch (failure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: failure.toDisplayMessage(),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Não foi possível carregar as mensagens.',
      );
    }
  }

  /// Carrega mensagens mais antigas (página seguinte) e faz prepend na lista.
  Future<void> loadOlderMessages() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);

    final nextPage = _currentPage + 1;
    try {
      final older = await ref
          .read(chatRepositoryProvider)
          .fetchMessages(_conversationId, page: nextPage);

      if (older.isEmpty) {
        state = state.copyWith(isLoadingMore: false, hasMore: false);
        return;
      }

      _currentPage = nextPage;
      // Filtra duplicatas e faz prepend (older vêm em ordem ascendente).
      final existingIds = state.messages.map((m) => m.id).toSet();
      final newer = older.where((m) => !existingIds.contains(m.id)).toList();

      state = state.copyWith(
        messages: [...newer, ...state.messages],
        isLoadingMore: false,
        hasMore: older.length >= AppConstants.chatPageLimit,
      );
    } catch (e) {
      debugPrint('loadOlderMessages failed: $e');
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void _handleIncomingMessage(ChatMessage message) {
    final messages = [...state.messages];
    final optimisticIndex = messages.indexWhere(
      (m) =>
          m.id.startsWith('local-') &&
          m.content == message.content &&
          m.senderId == message.senderId,
    );
    if (optimisticIndex >= 0) {
      messages[optimisticIndex] = message;
    } else if (messages.any((m) => m.id == message.id)) {
      return;
    } else {
      messages.add(message);
    }
    state = state.copyWith(messages: messages, clearErrorMessage: true);

    _autoMarkAsRead(message);
  }

  Future<void> _autoMarkAsRead(ChatMessage message) async {
    final myId = await ref.read(chatRepositoryProvider).getCurrentUserId();
    if (myId == null || message.senderId == myId) return;
    try {
      await ref
          .read(chatRepositoryProvider)
          .markMessagesRead(conversationId: _conversationId);
    } catch (_) {}
  }

  void _handleTypingIndicator(bool isTyping) {
    _typingStopTimer?.cancel();
    state = state.copyWith(isTyping: isTyping);

    if (isTyping) {
      _typingStopTimer = Timer(const Duration(seconds: 5), () {
        if (ref.mounted) state = state.copyWith(isTyping: false);
      });
    }
  }

  Future<void> sendMessage(String content, {ChatMessage? replyTo}) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    final optimisticMessage = await _buildOptimisticMessage(
      trimmed,
      replyTo: replyTo,
    );
    _appendMessage(optimisticMessage);
    state = state.copyWith(isSending: true, clearErrorMessage: true);

    try {
      final sent = await ref.read(chatRepositoryProvider).sendMessage(
            conversationId: _conversationId,
            message: trimmed,
            replyToMessageId: replyTo?.id,
          );
      // O backend não devolve o replyTo preview no POST → preservar do otimista.
      final merged = sent.copyWith(
        replyTo: sent.replyTo ?? optimisticMessage.replyTo,
        replyToMessageId:
            sent.replyToMessageId ?? optimisticMessage.replyToMessageId,
      );
      _replaceMessage(optimisticMessage.id, merged);
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
        errorMessage: 'Não foi possível enviar a mensagem.',
      );
    }
  }

  /// Toggle de reação numa mensagem. Aplica otimista local e sincroniza com backend.
  Future<void> reactToMessage(String messageId, String emoji) async {
    if (messageId.startsWith('local-')) return;

    final authState = ref.read(authStateProvider);
    final myId = authState is AsyncData<User?> ? authState.value?.id : null;
    if (myId == null) return;

    final current = state.messages.firstWhere(
      (m) => m.id == messageId,
      orElse: () => ChatMessage(
        id: messageId,
        conversationId: _conversationId,
        senderId: '',
        content: '',
        timestamp: DateTime.now(),
      ),
    );
    final snapshot = current.reactions;

    // Optimistic toggle local
    final next = <String, List<String>>{};
    snapshot.forEach((k, v) => next[k] = List<String>.from(v));
    final users = List<String>.from(next[emoji] ?? const []);
    if (users.contains(myId)) {
      users.remove(myId);
    } else {
      users.add(myId);
    }
    if (users.isEmpty) {
      next.remove(emoji);
    } else {
      next[emoji] = users;
    }
    _patchMessage(messageId, (m) => m.copyWith(reactions: next));

    try {
      final serverReactions = await ref
          .read(chatRepositoryProvider)
          .reactToMessage(messageId: messageId, emoji: emoji);
      _patchMessage(messageId, (m) => m.copyWith(reactions: serverReactions));
    } catch (e) {
      // Reverter em caso de falha
      _patchMessage(messageId, (m) => m.copyWith(reactions: snapshot));
      state = state.copyWith(
        errorMessage: 'Não foi possível reagir à mensagem.',
      );
    }
  }

  void _handleReactionUpdate(MessageReactionUpdate update) {
    _patchMessage(
      update.messageId,
      (m) => m.copyWith(reactions: update.reactions),
    );
  }

  void _patchMessage(
    String messageId,
    ChatMessage Function(ChatMessage) transform,
  ) {
    state = state.copyWith(
      messages: state.messages
          .map((m) => m.id == messageId ? transform(m) : m)
          .toList(growable: false),
    );
  }

  void onTyping() {
    ref
        .read(chatRepositoryProvider)
        .sendTypingStart(conversationId: _conversationId);
  }

  void onTypingStopped() {
    ref
        .read(chatRepositoryProvider)
        .sendTypingStop(conversationId: _conversationId);
  }

  Future<void> markAsRead() async {
    try {
      await ref
          .read(chatRepositoryProvider)
          .markMessagesRead(conversationId: _conversationId);
    } catch (_) {}
  }

  Future<ChatMessage> _buildOptimisticMessage(
    String content, {
    ChatMessage? replyTo,
  }) async {
    final authState = ref.read(authStateProvider);
    final currentUser = authState is AsyncData<User?> ? authState.value : null;
    final timestamp = DateTime.now();
    ReplyPreview? preview;
    if (replyTo != null) {
      preview = ReplyPreview(
        id: replyTo.id,
        senderId: replyTo.senderId,
        content: replyTo.messageType == 'image'
            ? ''
            : (replyTo.content.length > 120
                ? replyTo.content.substring(0, 120)
                : replyTo.content),
        messageType: replyTo.messageType,
        isBurned: replyTo.isBurned,
      );
    }
    return ChatMessage(
      id: 'local-${timestamp.microsecondsSinceEpoch}',
      conversationId: _conversationId,
      senderId: currentUser?.id ?? 'current-user',
      content: content,
      timestamp: timestamp,
      isPending: true,
      replyToMessageId: replyTo?.id,
      replyTo: preview,
    );
  }

  void _appendMessage(ChatMessage message) {
    state = state.copyWith(
      messages: [...state.messages, message],
      clearErrorMessage: true,
    );
  }

  void _replaceMessage(String oldId, ChatMessage newMessage) {
    state = state.copyWith(
      messages: state.messages
          .map((m) => m.id == oldId ? newMessage : m)
          .toList(growable: false),
    );
  }

  void _removeMessage(String messageId) {
    state = state.copyWith(
      messages:
          state.messages.where((m) => m.id != messageId).toList(growable: false),
    );
  }

  void _handleBurnEvent(String messageId) {
    state = state.copyWith(
      messages: state.messages
          .map((m) => m.id == messageId
              ? m.copyWith(isBurned: true, content: '')
              : m)
          .toList(growable: false),
    );
  }

  /// Envia uma imagem (com opção de view-once).
  Future<void> sendImage({
    required String filePath,
    bool viewOnce = false,
  }) async {
    final optimisticId = 'local-${DateTime.now().microsecondsSinceEpoch}';
    final authState = ref.read(authStateProvider);
    final currentUser = authState is AsyncData<User?> ? authState.value : null;
    final optimistic = ChatMessage(
      id: optimisticId,
      conversationId: _conversationId,
      senderId: currentUser?.id ?? 'current-user',
      content: filePath, // local path; bubble detecta via messageType
      timestamp: DateTime.now(),
      isPending: true,
      messageType: 'image',
      isViewOnce: viewOnce,
    );
    _appendMessage(optimistic);
    state = state.copyWith(isSending: true, clearErrorMessage: true);

    try {
      final sent = await ref.read(chatRepositoryProvider).uploadImage(
            conversationId: _conversationId,
            filePath: filePath,
            viewOnce: viewOnce,
          );
      _replaceMessage(optimisticId, sent);
      state = state.copyWith(isSending: false);
    } on Failure catch (failure) {
      _removeMessage(optimisticId);
      state = state.copyWith(
        isSending: false,
        errorMessage: failure.toDisplayMessage(),
      );
    } catch (_) {
      _removeMessage(optimisticId);
      state = state.copyWith(
        isSending: false,
        errorMessage: 'Não foi possível enviar a imagem.',
      );
    }
  }

  /// Marca uma view-once como visualizada/queimada (chamado quando o
  /// destinatário abre a imagem).
  Future<void> burnMessage(String messageId) async {
    // Update local imediato.
    _handleBurnEvent(messageId);
    try {
      await ref.read(chatRepositoryProvider).burnMessage(messageId);
    } catch (e) {
      debugPrint('burnMessage failed: $e');
    }
  }

  /// Apaga a mensagem (soft delete por participante).
  Future<void> deleteMessage(String messageId) async {
    final snapshot = state.messages;
    _removeMessage(messageId);
    try {
      await ref.read(chatRepositoryProvider).deleteMessage(messageId);
    } on Failure catch (failure) {
      state = state.copyWith(
        messages: snapshot,
        errorMessage: failure.toDisplayMessage(),
      );
    } catch (_) {
      state = state.copyWith(
        messages: snapshot,
        errorMessage: 'Não foi possível apagar a mensagem.',
      );
    }
  }
}
