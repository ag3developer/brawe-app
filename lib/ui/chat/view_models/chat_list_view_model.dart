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
    this.showArchived = false,
    this.errorMessage,
  });

  final List<Conversation> conversations;
  final bool isLoading;
  final bool showArchived;
  final String? errorMessage;

  ChatListState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    bool? showArchived,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ChatListState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      showArchived: showArchived ?? this.showArchived,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

@Riverpod(keepAlive: true)
class ChatListViewModel extends _$ChatListViewModel {
  StreamSubscription<ChatMessage>? _notificationsSubscription;
  Timer? _pollingTimer;

  @override
  ChatListState build() {
    ref.onDispose(() {
      _notificationsSubscription?.cancel();
      _pollingTimer?.cancel();
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

    // Polling a cada 15s para pegar novas conversas iniciadas pela outra pessoa
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _loadConversations(silent: true);
    });
  }

  Future<void> _loadConversations({bool silent = false}) async {
    if (!silent) state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final items = await ref
          .read(chatRepositoryProvider)
          .listConversations(archived: state.showArchived);
      debugPrint(
          '[ChatListViewModel] _loadConversations OK: ${items.length} conversas (archived=${state.showArchived})');
      state = state.copyWith(
        conversations: items,
        isLoading: false,
        clearErrorMessage: true,
      );
    } on Failure catch (failure) {
      debugPrint(
          '[ChatListViewModel] _loadConversations Failure: ${failure.toDisplayMessage()}');
      state = state.copyWith(
        isLoading: false,
        errorMessage: failure.toDisplayMessage(),
      );
    } catch (e, st) {
      debugPrint('[ChatListViewModel] _loadConversations error: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar conversas: $e',
      );
    }
  }

  Future<void> refresh() => _loadConversations();

  /// Alterna entre visualizar conversas ativas e arquivadas.
  Future<void> toggleArchived(bool value) async {
    state = state.copyWith(showArchived: value);
    await _loadConversations();
  }

  /// Arquiva uma conversa (otimista).
  Future<void> archive(String conversationId) async {
    final snapshot = state.conversations;
    state = state.copyWith(
      conversations:
          snapshot.where((c) => c.id != conversationId).toList(growable: false),
    );
    try {
      await ref
          .read(chatRepositoryProvider)
          .archiveConversation(conversationId);
    } catch (e) {
      debugPrint('archive failed: $e');
      state = state.copyWith(
        conversations: snapshot,
        errorMessage: 'Não foi possível arquivar a conversa',
      );
    }
  }

  Future<void> unarchive(String conversationId) async {
    final snapshot = state.conversations;
    state = state.copyWith(
      conversations:
          snapshot.where((c) => c.id != conversationId).toList(growable: false),
    );
    try {
      await ref
          .read(chatRepositoryProvider)
          .unarchiveConversation(conversationId);
    } catch (e) {
      debugPrint('unarchive failed: $e');
      state = state.copyWith(
        conversations: snapshot,
        errorMessage: 'Não foi possível desarquivar a conversa',
      );
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    final snapshot = state.conversations;
    state = state.copyWith(
      conversations:
          snapshot.where((c) => c.id != conversationId).toList(growable: false),
    );
    try {
      await ref
          .read(chatRepositoryProvider)
          .deleteConversation(conversationId);
    } catch (e) {
      debugPrint('deleteConversation failed: $e');
      state = state.copyWith(
        conversations: snapshot,
        errorMessage: 'Não foi possível apagar a conversa',
      );
    }
  }

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
