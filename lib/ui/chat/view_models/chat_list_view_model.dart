import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/chat_repository.dart';
import '../../../domain/models/conversation.dart';

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
  StreamSubscription<List<Conversation>>? _conversationsSubscription;

  @override
  ChatListState build() {
    ref.onDispose(() {
      _conversationsSubscription?.cancel();
    });

    _initialize();

    return const ChatListState();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      await ref.read(chatRepositoryProvider).connect();

      _conversationsSubscription = ref
          .read(chatRepositoryProvider)
          .watchConversations()
          .listen(_handleConversationsUpdate);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to connect to chat',
      );
    }
  }

  void _handleConversationsUpdate(List<Conversation> conversations) {
    state = state.copyWith(
      conversations: conversations,
      isLoading: false,
      clearErrorMessage: true,
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(chatRepositoryProvider).connect();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh conversations',
      );
    }
  }

  Future<void> startConversation({required String participantId}) async {
    try {
      await ref.read(chatRepositoryProvider).startConversation(
        participantId: participantId,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to start conversation',
      );
    }
  }
}
