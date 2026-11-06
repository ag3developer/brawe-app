import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/chat_repository.dart';

part 'unread_chats_provider.g.dart';

/// Regras puras do badge da aba Chat (testáveis sem Riverpod).
class UnreadChatsLogic {
  const UnreadChatsLogic._();

  /// Conversas não lidas após chegar uma mensagem. Não conta mensagem minha,
  /// nem a da conversa aberta no momento, nem payload sem conversa.
  static Set<String> onIncoming(
    Set<String> current, {
    required String conversationId,
    required String senderId,
    required String? myId,
    required String? activeConversationId,
  }) {
    if (conversationId.isEmpty) return current;
    if (myId != null && senderId == myId) return current;
    if (conversationId == activeConversationId) return current;
    if (current.contains(conversationId)) return current;
    return {...current, conversationId};
  }

  /// Conversa lida: sai do conjunto.
  static Set<String> onRead(Set<String> current, String conversationId) =>
      current.contains(conversationId)
      ? ({...current}..remove(conversationId))
      : current;

  /// Reconcilia com o servidor, ignorando a conversa aberta agora.
  static Set<String> reconcile(Set<String> server, String? activeId) =>
      activeId == null ? server : ({...server}..remove(activeId));

  /// Texto do badge: `null` esconde (0), "99+" acima de 99.
  static String? label(int count) {
    if (count <= 0) return null;
    return count > 99 ? '99+' : '$count';
  }
}

/// Conversas com mensagens não lidas (fonte do badge da aba Chat).
///
/// Verdade do servidor (`GET /messages/unread-count` → `conversation_ids`, sem
/// silenciadas) carregada no start/login/resume e a cada 60s; entre cargas, o
/// socket (`message_notification`) adiciona e a leitura remove.
@Riverpod(keepAlive: true)
class UnreadChats extends _$UnreadChats {
  Timer? _timer;
  StreamSubscription? _sub;
  String? _activeConversationId;

  /// Conversa aberta agora (não conta como não lida nem gera banner).
  String? get activeConversationId => _activeConversationId;

  @override
  Set<String> build() {
    ref.onDispose(() {
      _timer?.cancel();
      _sub?.cancel();
    });
    final userId = ref.watch(authStateProvider).value?.id;
    if (userId == null) return <String>{};

    final repo = ref.read(chatRepositoryProvider);
    () async {
      try {
        await repo.connect();
      } catch (_) {}
      if (!ref.mounted) return;
      _sub = repo.watchNotifications().listen((m) {
        state = UnreadChatsLogic.onIncoming(
          state,
          conversationId: m.conversationId,
          senderId: m.senderId,
          myId: userId,
          activeConversationId: _activeConversationId,
        );
      });
    }();

    refresh();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => refresh());
    return <String>{};
  }

  Future<void> refresh() async {
    try {
      final ids = await ref.read(chatRepositoryProvider).getUnreadConversationIds();
      if (ids != null && ref.mounted) {
        state = UnreadChatsLogic.reconcile(ids, _activeConversationId);
      }
    } catch (_) {}
  }

  /// A conversa foi aberta/lida.
  void markRead(String conversationId) {
    if (!ref.mounted) return;
    state = UnreadChatsLogic.onRead(state, conversationId);
  }

  /// Chamado ao abrir a conversa.
  void setActive(String conversationId) {
    _activeConversationId = conversationId;
    markRead(conversationId);
  }

  /// Ao sair da conversa (sem mexer em estado — seguro dentro de dispose).
  void clearActive() => _activeConversationId = null;
}
