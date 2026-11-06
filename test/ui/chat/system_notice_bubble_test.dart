import 'package:brawe_app/domain/models/conversation.dart';
import 'package:brawe_app/gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/chat/widgets/rich/system_notice_bubble.dart';
import 'package:brawe_app/ui/core/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {bool dark = false, Locale locale = const Locale('pt')}) => MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      locale: locale,
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      home: Scaffold(body: child),
    );

ChatMessage _msg(String tone, {bool cta = true, String? body}) => ChatMessage(
      id: 'm',
      conversationId: 'c',
      senderId: kBraweSystemUserIdForTest,
      content: 'fallback',
      timestamp: DateTime(2026, 11, 6),
      messageType: 'system_notice',
      meta: {
        'type': 'system_notice',
        'event': 'x',
        'title': 'Pedido de desligamento recusado com um título bem comprido para testar quebra de linha',
        'body': body ?? 'A agência Streamer Now Agency não aprovou seu pedido agora. Você poderá pedir de novo em 12/11/2026.\nResposta da agência: ${'texto ' * 30}',
        'icon': 'message-square-x',
        'tone': tone,
        'cta': cta ? {'label': 'Ver detalhes da agência e próximos passos', 'route': '/creator/agency'} : null,
      },
    );

const kBraweSystemUserIdForTest = '00000000-0000-4000-8000-00000000b2a3';

void main() {
  for (final dark in [false, true]) {
    for (final w in [320.0, 390.0]) {
      for (final tone in ['info', 'success', 'warning', 'danger']) {
        testWidgets('${dark ? "escuro" : "claro"} $w $tone sem overflow', (tester) async {
          tester.view.physicalSize = Size(w * 2, 800 * 2);
          tester.view.devicePixelRatio = 2;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(_app(
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Align(alignment: Alignment.centerLeft, child: SystemNoticeBubble(message: _msg(tone)))),
            dark: dark,
          ));
          await tester.pump();
          expect(tester.takeException(), isNull);
          expect(find.textContaining('Pedido de desligamento'), findsOneWidget);
        });
      }
    }
  }

  testWidgets('CTA chama a rota; sem CTA não mostra botão', (tester) async {
    String? opened;
    await tester.pumpWidget(_app(SystemNoticeBubble(message: _msg('info'), onCta: (r) => opened = r)));
    await tester.tap(find.byType(FilledButton));
    expect(opened, '/creator/agency');
    await tester.pumpWidget(_app(SystemNoticeBubble(message: _msg('info', cta: false))));
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('CTA com url externa chama onUrl (não a rota)', (tester) async {
    String? url;
    String? route;
    final m = ChatMessage(
      id: 'm', conversationId: 'c', senderId: kBraweSystemUserIdForTest, content: 'x', timestamp: DateTime(2026), messageType: 'system_notice',
      meta: {'title': 'Convite', 'body': 'b', 'cta': {'label': 'Aceitar convite', 'url': 'https://partners.brawe.app/team/invite/abc'}},
    );
    await tester.pumpWidget(_app(SystemNoticeBubble(message: m, onCta: (r) => route = r, onUrl: (u) => url = u)));
    await tester.tap(find.byType(FilledButton));
    expect(url, 'https://partners.brawe.app/team/invite/abc');
    expect(route, isNull);
  });

  testWidgets('sem meta mostra o texto simples', (tester) async {
    final m = ChatMessage(id: 'm', conversationId: 'c', senderId: 's', content: 'Texto antigo', timestamp: DateTime(2026), messageType: 'system_notice');
    await tester.pumpWidget(_app(SystemNoticeBubble(message: m)));
    expect(find.text('Texto antigo'), findsOneWidget);
  });

  testWidgets('rodapé somente leitura em pt/en/es, claro e escuro', (tester) async {
    for (final e in {'pt': 'Mensagens oficiais da Brawe', 'en': 'Official Brawe messages', 'es': 'Mensajes oficiales de Brawe'}.entries) {
      for (final dark in [false, true]) {
        await tester.pumpWidget(_app(const Align(alignment: Alignment.bottomCenter, child: SystemReadOnlyFooter()), dark: dark, locale: Locale(e.key)));
        await tester.pump();
        expect(find.text(e.value), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
        expect(tester.takeException(), isNull);
      }
    }
  });

  test('rotas: convite é de tela cheia (push); demais usam go', () {
    expect(isTopLevelNoticeRoute('/creator/agency/invite/abc'), isTrue);
    expect(isTopLevelNoticeRoute('/creator/dashboard'), isFalse);
  });
}
