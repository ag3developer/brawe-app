import 'dart:ui';

import 'package:brawe_app/domain/models/live_moderation.dart';
import 'package:brawe_app/gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/live/shared/widgets/chat/chat_error_text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  final now = DateTime(2026, 11, 1, 20, 0, 0);
  ChatError err(ChatErrorKind k, {DateTime? until, String? msg}) =>
      ChatError(kind: k, until: until, serverMessage: msg, at: now);

  Future<S> load(String lang) => S.delegate.load(Locale(lang));

  test('muted shows local HH:mm', () async {
    final until = DateTime.utc(2026, 11, 1, 21, 30);
    final hhmm = DateFormat('HH:mm').format(until.toLocal());
    expect(
      chatErrorText(await load('pt'), err(ChatErrorKind.muted, until: until)),
      'Você foi silenciado até $hhmm',
    );
    expect(
      chatErrorText(await load('en'), err(ChatErrorKind.muted, until: until)),
      'You were muted until $hhmm',
    );
    expect(
      chatErrorText(await load('es'), err(ChatErrorKind.muted, until: until)),
      contains(hhmm),
    );
  });

  test('muted without until = end of the live', () async {
    expect(
      chatErrorText(await load('pt'), err(ChatErrorKind.muted)),
      'Você foi silenciado até o fim da live',
    );
    expect(
      chatErrorText(await load('en'), err(ChatErrorKind.muted)),
      'You were muted until the end of the live',
    );
  });

  test('never leaks the server pt message in en/es', () async {
    for (final lang in ['en', 'es']) {
      final s = await load(lang);
      for (final k in ChatErrorKind.values) {
        final t = chatErrorText(s, err(k, msg: 'Mensagem bloqueada pelo servidor'));
        expect(t.contains('servidor'), isFalse, reason: '$lang $k');
        expect(t, isNotEmpty);
      }
    }
  });

  test('blocked word and unknown share the short message', () async {
    final pt = await load('pt');
    expect(chatErrorText(pt, err(ChatErrorKind.blockedWord)), 'Mensagem não enviada');
    expect(chatErrorText(pt, err(ChatErrorKind.unknown)), 'Mensagem não enviada');
    expect(chatErrorText(pt, err(ChatErrorKind.link)), contains('Links'));
    expect(chatErrorText(pt, err(ChatErrorKind.phone)), contains('Telefones'));
  });

  test('slow mode counts down to until', () async {
    final pt = await load('pt');
    expect(
      chatErrorText(
        pt,
        err(ChatErrorKind.slowMode, until: now.add(const Duration(milliseconds: 2400))),
        now: now,
      ),
      'Modo lento: aguarde 3 s',
    );
    expect(chatErrorText(pt, err(ChatErrorKind.slowMode), now: now),
        'Modo lento: aguarde um instante');
    expect(pt.chatSlowModeHint(3), 'Modo lento: 3 s');
  });
}
