import 'package:brawe_app/domain/models/conversation.dart';
import 'package:brawe_app/domain/models/system_notice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final meta = {
    'type': 'system_notice',
    'event': 'creator_approved',
    'title': 'Você foi aprovado(a)!',
    'body': 'Seu perfil de creator já está ativo.',
    'icon': 'badge-check',
    'tone': 'success',
    'cta': {'label': 'Abrir painel', 'route': '/creator/dashboard'},
    'ref': {'kind': 'application', 'id': 'a1'},
  };

  test('ChatMessage.fromApi lê meta e expõe o aviso', () {
    final m = ChatMessage.fromApi({
      'id': '1',
      'conversation_id': 'c',
      'sender_id': kBraweSystemUserId,
      'content': 'Você foi aprovado(a)!\nSeu perfil de creator já está ativo.',
      'message_type': 'system_notice',
      'meta': meta,
    });
    final n = m.systemNotice!;
    expect(n.title, 'Você foi aprovado(a)!');
    expect(n.tone, SystemNoticeTone.success);
    expect(n.icon, 'badge-check');
    expect(n.cta!.route, '/creator/dashboard');
    expect(n.refKind, 'application');
    expect(m.payload, isNotNull);
  });

  test('sem meta (ou tipo comum) não há aviso; tom desconhecido vira info; CTA inválida é ignorada', () {
    expect(ChatMessage.fromApi({'id': '1', 'content': 'oi', 'message_type': 'system_notice'}).systemNotice, isNull);
    expect(ChatMessage.fromApi({'id': '1', 'content': 'oi', 'message_type': 'text', 'meta': meta}).systemNotice, isNull);
    final n = SystemNotice.fromJson({'title': 'T', 'tone': 'xyz', 'cta': {'label': 'x', 'route': 'sem-barra'}})!;
    expect(n.tone, SystemNoticeTone.info);
    expect(n.cta, isNull);
    expect(SystemNotice.fromJson({}), isNull);
  });

  test('Conversation.fromApi marca a conversa oficial', () {
    final c = Conversation.fromApi({
      'id': 'c1',
      'other_user_id': kBraweSystemUserId,
      'other_user_name': 'Brawe',
      'other_user_is_verified': true,
      'is_pinned': true,
    });
    expect(c.isSystem, isTrue);
    expect(c.participantIsVerified, isTrue);
    expect(Conversation.fromApi({'id': 'c2', 'other_user_id': 'u'}).isSystem, isFalse);
    expect(Conversation.fromApi({'id': 'c3', 'other_user_id': 'u', 'is_system': true}).isSystem, isTrue);
  });
}
