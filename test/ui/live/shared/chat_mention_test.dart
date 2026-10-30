import 'package:brawe_app/domain/models/live_comment.dart';
import 'package:brawe_app/ui/live/shared/widgets/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

LiveComment _comment({String? username, String name = 'Ana Souza'}) =>
    LiveComment(
      id: '1',
      userId: 'u1',
      userName: name,
      username: username,
      message: 'oi',
      timestamp: DateTime(2026),
    );

void main() {
  group('ChatUserSheet.insertMention', () {
    test('usa @username quando o servidor envia', () {
      final c = TextEditingController();
      ChatUserSheet.insertMention(c, _comment(username: 'ana'));
      expect(c.text, '@ana ');
      expect(c.selection.baseOffset, c.text.length);
    });

    test('cai no nome de exibição sem username', () {
      final c = TextEditingController();
      ChatUserSheet.insertMention(c, _comment());
      expect(c.text, '@Ana Souza ');
    });

    test('troca a menção anterior e mantém o texto digitado', () {
      final c = TextEditingController(text: '@bob tudo bem?');
      ChatUserSheet.insertMention(c, _comment(username: 'ana'));
      expect(c.text, '@ana tudo bem?');
    });
  });

  testWidgets('ChatTicker destaca menção a mim e abre o cartão no toque', (
    tester,
  ) async {
    LiveComment? tapped;
    final other = LiveComment(
      id: '2',
      userId: 'u2',
      userName: 'Bia',
      username: 'bia',
      message: 'oi @eu',
      timestamp: DateTime(2026),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatTicker(
            comments: [other],
            gifts: const [],
            myUserId: 'me',
            myUsername: 'eu',
            onCommentTap: (c) => tapped = c,
          ),
        ),
      ),
    );
    final line = tester.widget<ChatLine>(find.byType(ChatLine));
    expect(line.mentionsMe, isTrue);
    await tester.tap(find.byType(ChatLine));
    expect(tapped?.id, '2');
  });
}
