import 'package:brawe_app/data/services/push_grouping.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mesma conversa => mesma chave e mesmo id local (substitui)', () {
    final a = {'type': 'new_message', 'conversation_id': 'c-1'};
    final b = {'type': 'new_message', 'conversationId': 'c-1'};
    expect(PushGrouping.groupKey(a), 'c-1');
    expect(PushGrouping.groupKey(b), 'c-1');
    expect(PushGrouping.notificationId('c-1'),
        PushGrouping.notificationId('c-1'));
    expect(PushGrouping.notificationId('c-1') >= 0, isTrue);
    expect(PushGrouping.notificationId('c-1'),
        isNot(PushGrouping.notificationId('c-2')));
  });

  test('push que não é de mensagem não agrupa', () {
    expect(PushGrouping.groupKey({'type': 'post_liked', 'postId': 'p'}), isNull);
  });

  test('suprime banner só na conversa aberta', () {
    final d = {'type': 'new_message', 'conversation_id': 'c-1'};
    expect(PushGrouping.shouldSuppress(d, 'c-1'), isTrue);
    expect(PushGrouping.shouldSuppress(d, 'c-2'), isFalse);
    expect(PushGrouping.shouldSuppress(d, null), isFalse);
  });
}
