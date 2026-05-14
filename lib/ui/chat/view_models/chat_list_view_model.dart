import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/chat_repository.dart';
import '../../../domain/models/conversation.dart';
import '../../../domain/models/failure.dart';

part 'chat_list_view_model.g.dart';

class ChatListState {
  const ChatListState({
    this.conversations = const <Conversation>[],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Conversation> conversations;
  final bool isLoading;
  final String? errorMessage;

  ChatListState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ChatListState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class ChatListViewModel extends _$ChatListViewModel {
  StreamSubscription<ChatMessage>? _notificationsSubscription;

  @override
  ChatListState build() {
    ref.onDispose(() {
      _notificationsSubscription?.cancel();
    });

    _initialize();
    return const ChatListState(isLoading: true);
  }

  Future<void> _initialize() async {
    final repo = ref.read(chatRepositoryProvider);
    try {
      await repo.connect();
    } catch (e) {
      debugPrint('ChatListViewModel: socket connect failed: $e');
    }

    await _loadConversations();

    // Quando chega notificação de nova mensagem em outra conversa, recarrega lista
    _notificationsSubscription =
        repo.watchNotifications().listen((_) => _loadConversations(silent: true));
  }

  Future<void> _loadConversations({bool silent = false}) async {
    if (!silent) state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final items =
          await ref.read(chatRepositoryProvider).listConversations();
      state = state.copyWith(
        conversations: items,
        isLoading: false,
        clearErrorMessage: true,
      );
    } on Failure catch (failure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: failure.toDisplayMessage(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar conversas',
      );
    }
  }

  Future<void> refresh() => _loadConversations();

  /// Inicia (ou reaproveita) conversa e retorna o id, para navegação.
  Future<String?> startConversation({required String participantId}) async {
    try {
      final id = await ref
          .read(chatRepositoryProvider)
          .startConversation(participantId: participantId);
      await _loadConversations(silent: true);
      return id;
    } on Failure catch (failure) {
      state = state.copyWith(errorMessage: failure.toDisplayMessage());
      return null;
    } catch (_) {
      state = state.copyWith(errorMessage: 'Não foi possível iniciar a conversa');
      return null;
    }
  }
}
