import 'package:brawe_app/data/services/security_service.dart';
import 'package:brawe_app/domain/models/account_security.dart';
import 'package:brawe_app/ui/settings/widgets/security_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'security_test_support.dart';

Future<void> _open(
  WidgetTester tester,
  FakeSecurityService svc, {
  bool openProtect = false,
  double w = 390,
  double textScale = 1,
  bool dark = false,
}) async {
  setScreen(tester, w, 844);
  await tester.pumpWidget(
    securityApp(
      overrides: securityOverrides(svc),
      textScale: textScale,
      dark: dark,
      home: SecurityScreen(openProtect: openProtect),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _goTab(WidgetTester t, String name) async {
  await t.ensureVisible(find.text(name).first);
  await t.tap(find.text(name).first);
  await t.pumpAndSettle();
}

void main() {
  group('Aparelhos conectados', () {
    testWidgets('lista com badge "Este aparelho" só na sessão atual', (t) async {
      await _open(t, FakeSecurityService());
      expect(find.text('Este aparelho'), findsOneWidget);
      expect(find.text('iPhone 15 Pro'), findsOneWidget);
      expect(find.text('Samsung SM-S918B'), findsOneWidget);
      expect(find.text('Encerrar sessão'), findsWidgets);
      // a sessão atual não tem "Encerrar sessão"
      final cur = find.byKey(const Key('session-s1'));
      expect(
        find.descendant(of: cur, matching: find.text('Encerrar sessão')),
        findsNothing,
      );
      await t.dragUntilVisible(
        find.text('IP Geolocation by DB-IP'),
        find.byType(ListView).first,
        const Offset(0, -200),
      );
      expect(find.text('Sair de todos os outros aparelhos'), findsOneWidget);
      expect(find.text('IP Geolocation by DB-IP'), findsOneWidget);
    });

    testWidgets('carregando', (t) async {
      setScreen(t, 390, 844);
      await t.pumpWidget(
        securityApp(
          overrides: securityOverrides(FakeSecurityService()),
          home: const SecurityScreen(),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await t.pumpAndSettle();
    });

    testWidgets('vazio', (t) async {
      await _open(t, FakeSecurityService(list: []));
      expect(find.text('Nenhuma sessão ativa encontrada.'), findsOneWidget);
    });

    testWidgets('erro com tentar novamente', (t) async {
      final svc = FakeSecurityService(
        sessionsError: const SecurityException(SecurityErrorKind.network),
      );
      await _open(t, svc);
      expect(find.text('Não foi possível carregar agora.'), findsOneWidget);
      svc.sessionsError = null;
      await t.tap(find.text('Tentar novamente'));
      await t.pumpAndSettle();
      expect(find.text('iPhone 15 Pro'), findsOneWidget);
    });

    testWidgets('404 (endpoint não publicado) vira aviso amigável', (t) async {
      final svc = FakeSecurityService(
        sessionsError: const SecurityException(SecurityErrorKind.unavailable),
      );
      await _open(t, svc);
      expect(find.textContaining('ainda não está disponível'), findsOneWidget);
      final ex = SecurityException.from(
        DioException(
          requestOptions: RequestOptions(path: '/auth/sessions'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/sessions'),
            statusCode: 404,
          ),
        ),
      );
      expect(ex.kind, SecurityErrorKind.unavailable);
    });

    testWidgets('encerrar uma sessão pede confirmação e chama a API', (t) async {
      final svc = FakeSecurityService();
      await _open(t, svc);
      await t.tap(
        find.descendant(
          of: find.byKey(const Key('session-s2')),
          matching: find.text('Encerrar sessão'),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Encerrar a sessão neste aparelho?'), findsOneWidget);
      // cancelar não revoga
      await t.tap(find.text('Cancelar'));
      await t.pumpAndSettle();
      expect(svc.revoked, isEmpty);
      await t.tap(
        find.descendant(
          of: find.byKey(const Key('session-s2')),
          matching: find.text('Encerrar sessão'),
        ),
      );
      await t.pumpAndSettle();
      await t.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Encerrar sessão'),
        ),
      );
      await t.pumpAndSettle();
      expect(svc.revoked, ['s2']);
      expect(find.byKey(const Key('session-s2')), findsNothing);
    });

    testWidgets('sair de todos os outros aparelhos', (t) async {
      final svc = FakeSecurityService();
      await _open(t, svc);
      await t.dragUntilVisible(
        find.text('Sair de todos os outros aparelhos'),
        find.byType(ListView).first,
        const Offset(0, -200),
      );
      await t.ensureVisible(find.text('Sair de todos os outros aparelhos'));
      await t.pumpAndSettle();
      await t.tap(find.text('Sair de todos os outros aparelhos'));
      await t.pumpAndSettle();
      await t.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Sair de todos os outros aparelhos'),
        ),
      );
      await t.pumpAndSettle();
      expect(svc.revokeOthersCalls, 1);
      expect(find.text('Nenhum outro aparelho conectado.'), findsOneWidget);
    });
  });

  group('Histórico', () {
    testWidgets('mapeia evento -> rótulo, ícone e cor', (t) async {
      await _open(t, FakeSecurityService());
      await _goTab(t, 'Histórico');
      expect(find.text('Login'), findsWidgets);
      expect(find.text('Tentativa de login falhou'), findsOneWidget);
      expect(find.text('Login bloqueado'), findsOneWidget);
      expect(find.text('Verificação pedida'), findsOneWidget);
      // ícones por evento
      expect(securityEventIcon(SecurityEventType.loginBlocked), LucideIcons.ban);
      expect(securityEventIcon(SecurityEventType.qrLogin), LucideIcons.qrCode);
    });

    testWidgets('filtros Logins / Falhas / Alterações', (t) async {
      await _open(t, FakeSecurityService());
      await _goTab(t, 'Histórico');
      await t.tap(find.byKey(const Key('filter-failures')));
      await t.pumpAndSettle();
      expect(find.text('Tentativa de login falhou'), findsOneWidget);
      expect(find.text('Login bloqueado'), findsOneWidget);
      expect(find.text('Senha alterada'), findsNothing);
      await t.tap(find.byKey(const Key('filter-changes')));
      await t.pumpAndSettle();
      expect(find.text('Senha alterada'), findsOneWidget);
      expect(find.text('Outros aparelhos desconectados'), findsOneWidget);
      await t.tap(find.byKey(const Key('filter-logins')));
      await t.pumpAndSettle();
      expect(find.text('Login por QR code'), findsOneWidget);
      expect(find.text('Login bloqueado'), findsNothing);
    });

    testWidgets('paginação carrega a próxima página', (t) async {
      final svc = FakeSecurityService(pageSize: 5);
      await _open(t, svc);
      await _goTab(t, 'Histórico');
      expect(svc.pagesRequested, [1]);
      await t.dragUntilVisible(
        find.text('Carregar mais'),
        find.byType(ListView).last,
        const Offset(0, -200),
      );
      await t.tap(find.text('Carregar mais'));
      await t.pumpAndSettle();
      expect(svc.pagesRequested, [1, 2]);
    });

    testWidgets('erro mostra tentar novamente', (t) async {
      final svc = FakeSecurityService(
        eventsError: const SecurityException(SecurityErrorKind.server),
      );
      await _open(t, svc);
      await _goTab(t, 'Histórico');
      expect(find.text('Tentar novamente'), findsOneWidget);
    });
  });

  group('Proteger conta', () {
    testWidgets('secure=1 abre a folha de confirmação direto', (t) async {
      await _open(t, FakeSecurityService(), openProtect: true);
      expect(find.text('Proteger sua conta'), findsOneWidget);
      expect(find.textContaining('senha nova'), findsWidgets);
    });

    testWidgets('confirmar chama secure-account e abre a nova senha', (t) async {
      final svc = FakeSecurityService();
      var opened = 0;
      setScreen(t, 390, 844);
      await t.pumpWidget(
        securityApp(
          overrides: securityOverrides(svc),
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ProtectAccountSheet(onDone: () => opened++),
            ),
          ),
        ),
      );
      await t.tap(find.byKey(const Key('protect-confirm')));
      await t.pumpAndSettle();
      expect(svc.secureCalls, 1);
      expect(opened, 1);
    });

    testWidgets('aba Proteção tem o card e o botão', (t) async {
      await _open(t, FakeSecurityService());
      await _goTab(t, 'Proteção');
      expect(find.text('Não reconhece um acesso?'), findsOneWidget);
      expect(find.text('Proteger minha conta'), findsOneWidget);
      expect(find.text('Alterar senha'), findsOneWidget);
    });
  });

  group('Modelos', () {
    test('modelo e filtros', () {
      expect(SecurityEventType.parse('step_up_passed'), SecurityEventType.stepUpPassed);
      expect(SecurityEventType.parse('???'), SecurityEventType.unknown);
      final e = SecurityEvent.fromJson({
        'id': 1,
        'event': 'login_blocked',
        'success': true,
        'at': '2026-11-06T10:00:00Z',
      });
      expect(e.isFailure, isTrue);
      expect(SecurityEventFilter.failures.matches(e), isTrue);
      expect(SecurityEventFilter.logins.matches(e), isFalse);
    });
  });

  group('Layout sem overflow', () {
    for (final w in [320.0, 390.0, 412.0]) {
      for (final dark in [false, true]) {
        for (final tab in ['Aparelhos', 'Histórico', 'Proteção']) {
          testWidgets('$tab ${w.toInt()} ${dark ? 'dark' : 'light'} 200%', (t) async {
            await _open(t, FakeSecurityService(), w: w, textScale: 2, dark: dark);
            await t.ensureVisible(find.text(tab).first);
            await t.tap(find.text(tab).first);
            await t.pumpAndSettle();
            expect(t.takeException(), isNull);
          });
        }
      }
    }

    testWidgets('folha de proteção 320 200%', (t) async {
      await _open(t, FakeSecurityService(), openProtect: true, w: 320, textScale: 2);
      expect(t.takeException(), isNull);
    });
  });
}
