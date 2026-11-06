import 'dart:async';
import 'package:brawe_app/data/repositories/auth_state_provider.dart';
import 'package:brawe_app/data/repositories/chat_repository.dart';
import 'package:brawe_app/domain/models/conversation.dart';
import 'package:brawe_app/domain/models/user.dart';
import 'package:brawe_app/ui/chat/view_models/unread_chats_provider.dart';
import 'package:brawe_app/ui/chat/widgets/unread_badge.dart';
import 'package:brawe_app/ui/core/themes/brawe_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UnreadChatsLogic', () {
    test('mensagem de outra pessoa adiciona a conversa', () {
      final r = UnreadChatsLogic.onIncoming(
        {},
        conversationId: 'c1',
        senderId: 'u2',
        myId: 'me',
        activeConversationId: null,
      );
      expect(r, {'c1'});
    });

    test('mensagem minha ou conversa aberta não conta', () {
      expect(
        UnreadChatsLogic.onIncoming({}, conversationId: 'c1', senderId: 'me',
            myId: 'me', activeConversationId: null),
        isEmpty,
      );
      expect(
        UnreadChatsLogic.onIncoming({}, conversationId: 'c1', senderId: 'u2',
            myId: 'me', activeConversationId: 'c1'),
        isEmpty,
      );
    });

    test('várias mensagens da mesma conversa contam uma vez', () {
      var s = <String>{};
      for (var i = 0; i < 5; i++) {
        s = UnreadChatsLogic.onIncoming(s, conversationId: 'c1',
            senderId: 'u2', myId: 'me', activeConversationId: null);
      }
      expect(s.length, 1);
    });

    test('leitura remove; reconcile ignora a conversa aberta', () {
      expect(UnreadChatsLogic.onRead({'a', 'b'}, 'a'), {'b'});
      expect(UnreadChatsLogic.onRead({'a'}, 'zz'), {'a'});
      expect(UnreadChatsLogic.reconcile({'a', 'b'}, 'b'), {'a'});
    });

    test('label: 0 oculto, 1..99, 99+', () {
      expect(UnreadChatsLogic.label(0), isNull);
      expect(UnreadChatsLogic.label(1), '1');
      expect(UnreadChatsLogic.label(99), '99');
      expect(UnreadChatsLogic.label(100), '99+');
    });
  });

  group('UnreadChats provider', () {
    test('carrega do servidor, socket incrementa, leitura decrementa', () async {
      final repo = _FakeChatRepo({'c1'});
      final c = ProviderContainer(overrides: [
        chatRepositoryProvider.overrideWithValue(repo),
        authStateProvider.overrideWith(_FakeAuth.new),
      ]);
      addTearDown(c.dispose);

      c.listen(unreadChatsProvider, (_, _) {});
      await pumpEventQueue();
      expect(c.read(unreadChatsProvider), {'c1'});

      repo.push(_msg('c2', 'u2'));
      await pumpEventQueue();
      expect(c.read(unreadChatsProvider), {'c1', 'c2'});

      c.read(unreadChatsProvider.notifier).markRead('c1');
      expect(c.read(unreadChatsProvider), {'c2'});

      // Conversa aberta não conta.
      c.read(unreadChatsProvider.notifier).setActive('c3');
      repo.push(_msg('c3', 'u2'));
      await pumpEventQueue();
      expect(c.read(unreadChatsProvider), {'c2'});
    });
  });

  group('UnreadBadge', () {
    Future<void> pump(WidgetTester t, int count, ThemeData theme,
        {double width = 360}) async {
      t.view.physicalSize = Size(width, 600);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Center(
            child: UnreadBadge(
              count: count,
              semanticsLabel: 'Chat, $count',
              child: const Icon(Icons.chat_bubble_outline),
            ),
          ),
        ),
      ));
    }

    for (final entry in {
      'claro': ThemeData(brightness: Brightness.light, extensions: [BraweColors.light]),
      'escuro': ThemeData(brightness: Brightness.dark, extensions: [BraweColors.dark]),
    }.entries) {
      testWidgets('0 oculto, 1, 99, 99+ (${entry.key}, 320px)', (t) async {
        await pump(t, 0, entry.value, width: 320);
        expect(find.byKey(const ValueKey('unread-badge')), findsNothing);
        await pump(t, 1, entry.value, width: 320);
        expect(find.text('1'), findsOneWidget);
        await pump(t, 99, entry.value, width: 320);
        expect(find.text('99'), findsOneWidget);
        await pump(t, 150, entry.value, width: 320);
        expect(find.text('99+'), findsOneWidget);
        expect(t.takeException(), isNull);
      });
    }
  });
}

ChatMessage _msg(String conv, String sender) => ChatMessage(
      id: 'n',
      conversationId: conv,
      senderId: sender,
      content: 'x',
      timestamp: DateTime(2026),
    );

class _FakeAuth extends AuthState {
  @override
  Future<User?> build() async => User(
        id: 'me', email: 'a@b.c', name: 'Me', userType: 'user',
        displayId: '1', firstName: 'M', lastName: 'e', createdAt: '2026-01-01',
      );
}

class _FakeChatRepo extends Fake implements ChatRepository {
  _FakeChatRepo(this.ids);
  final Set<String> ids;
  final _c = StreamController<ChatMessage>.broadcast();
  void push(ChatMessage m) => _c.add(m);
  @override
  Future<void> connect() async {}
  @override
  Stream<ChatMessage> watchNotifications() => _c.stream;
  @override
  Future<Set<String>?> getUnreadConversationIds() async => ids;
}
