import 'dart:convert';

import 'package:brawe_app/data/services/creator_network_service.dart';
import 'package:brawe_app/domain/models/creator_network.dart';
import 'package:brawe_app/gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/core/themes/app_theme.dart';
import 'package:brawe_app/ui/creator/view_models/creator_applicant_provider.dart';
import 'package:brawe_app/ui/creator/view_models/creator_network_view_model.dart';
import 'package:brawe_app/ui/creator/widgets/creator_application_form_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Servidor falso: responde como o backend (201 + corpo da inscrição).
class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions) respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<List<int>>? s,
      Future<void>? c) {
    requests.add(o);
    return respond(o);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int code, Object body) => ResponseBody.fromString(
      jsonEncode(body),
      code,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

final _saved = {
  'id': '3f6b1b1e-0000-4000-8000-000000000001',
  'user_id': 'u1',
  'full_name': 'Ana Souza',
  'username': 'ana',
  'email': 'ana@exemplo.com',
  'country': 'BR',
  'city': null,
  'language': 'pt',
  'niche': 'games',
  'requested_tier': null,
  'suggested_tier': 'rising',
  'social_links': {'instagram': 'ana'},
  'followers_count': 1200,
  'does_live': true,
  'bio': null,
  'motivation': 'Quero crescer minha comunidade com lives.',
  'goals': null,
  'portfolio_url': null,
  'status': 'pending_review',
  'priority': 'normal',
  'classifier_score': 30,
  'rejection_reason': null,
  'reviewed_at': null,
  'created_at': '2026-11-06T12:00:00Z',
  'updated_at': '2026-11-06T12:00:00Z',
  'user': null,
};

CreatorNetworkService _serviceWith(_Adapter a) {
  final dio = Dio(BaseOptions(baseUrl: 'https://x.test/api/v1'))
    ..httpClientAdapter = a;
  return CreatorNetworkService(dio);
}

class _FakeService extends CreatorNetworkService {
  _FakeService({this.failWith, this.savedAfterFailure = false})
      : super(Dio());
  final DioException? failWith;
  final bool savedAfterFailure;
  Map<String, dynamic>? sentBody;
  int submitCalls = 0;

  @override
  Future<CreatorApplication> submitApplication(
      Map<String, dynamic> body) async {
    submitCalls++;
    sentBody = body;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (failWith != null) throw failWith!;
    return CreatorApplication.fromJson(_saved);
  }

  @override
  Future<String?> getCreatorTermsVersion() async => '2026-05-01';

  @override
  Future<CreatorApplication?> getMyApplication() async {
    if (!savedAfterFailure) return null;
    return CreatorApplication.fromJson({
      ..._saved,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}

void main() {
  group('POST /creator/applications (service)', () {
    for (final entry in {
      'corpo direto': _saved,
      'envelope data': {'success': true, 'data': _saved},
    }.entries) {
      test('201 com ${entry.key} vira a inscrição', () async {
        final svc = _serviceWith(_Adapter((_) async => _json(201, entry.value)));
        final app = await svc.submitApplication({'country': 'BR'});
        expect(app.status, ApplicationStatus.pendingReview);
        expect(app.username, 'ana');
      });
    }

    test('201 com corpo vazio ou fora do formato NÃO é erro', () async {
      for (final body in [<String, dynamic>{}, <dynamic>[], 'ok']) {
        final svc = _serviceWith(_Adapter((_) async => _json(201, body)));
        final app = await svc.submitApplication({'country': 'BR'});
        expect(app.status, ApplicationStatus.pendingReview);
      }
    });

    test('422 continua sendo erro (Dio)', () async {
      final svc = _serviceWith(_Adapter((_) async => _json(422, {
            'detail': 'x',
          })));
      expect(svc.submitApplication({}), throwsA(isA<DioException>()));
    });
  });

  group('controller sobrevive ao dispose do provider autoDispose', () {
    test('submit conclui com sucesso mesmo sem ninguém observando', () async {
      final fake = _FakeService();
      final container = ProviderContainer(overrides: [
        creatorNetworkServiceProvider.overrideWithValue(fake),
      ]);
      addTearDown(container.dispose);
      // Igual ao formulário real antes da correção: só `read`, sem listen.
      final app = await container
          .read(creatorApplicationFormControllerProvider.notifier)
          .submit(
            country: 'BR',
            language: 'pt',
            niche: ContentNiche.games,
            platform: 'instagram',
            handle: 'ana',
            followersCount: 1200,
            doesLive: true,
            motivation: 'Quero crescer minha comunidade com lives.',
            termsAccepted: true,
          );
      expect(app.status, ApplicationStatus.pendingReview);
      expect(fake.sentBody!['social_links'], {'instagram': 'ana'});
    });

    test('corpo enviado não tem campos removidos nem identidade', () async {
      final fake = _FakeService();
      final container = ProviderContainer(overrides: [
        creatorNetworkServiceProvider.overrideWithValue(fake),
      ]);
      addTearDown(container.dispose);
      container.listen(creatorApplicationFormControllerProvider, (_, _) {});
      await container
          .read(creatorApplicationFormControllerProvider.notifier)
          .submit(
            country: 'BR',
            language: 'pt',
            niche: ContentNiche.games,
            platform: 'tiktok',
            handle: 'ana',
            followersCount: 5,
            doesLive: false,
            motivation: 'Quero crescer minha comunidade com lives.',
            termsAccepted: true,
            termsVersion: '2026-05-01',
          );
      final keys = fake.sentBody!.keys.toSet();
      expect(
        keys.intersection({
          'full_name', 'username', 'email', 'phone', 'city', 'bio',
          'goals', 'portfolio_url', 'requested_tier',
        }),
        isEmpty,
      );
      expect(keys, containsAll(['country', 'niche', 'social_links',
          'followers_count', 'does_live', 'motivation', 'terms_accepted']));
    });
  });

  group('validação do @', () {
    test('aceita com ou sem @, recusa URL e espaços internos', () {
      expect(isValidCreatorHandle('@ana.lives'), isTrue);
      expect(isValidCreatorHandle('ana_lives-1'), isTrue);
      expect(isValidCreatorHandle('a'), isFalse);
      expect(isValidCreatorHandle('https://instagram.com/ana'), isFalse);
      expect(isValidCreatorHandle('ana lives'), isFalse);
      expect(normalizeCreatorHandle('  @@ana '), 'ana');
    });
  });

  group('formulário (widget)', () {
    Future<_FakeService> pumpForm(WidgetTester tester, _FakeService fake) async {
      tester.view.physicalSize = const Size(900, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final router = GoRouter(
        initialLocation: '/creator/apply',
        routes: [
          GoRoute(
              path: '/creator/apply',
              builder: (_, _) => const CreatorApplicationFormScreen()),
          GoRoute(
              path: '/creator/submitted',
              builder: (_, _) => const Scaffold(body: Text('SUBMITTED_OK'))),
          GoRoute(
              path: '/creator/status',
              builder: (_, _) => const Scaffold(body: Text('STATUS'))),
        ],
      );
      await tester.pumpWidget(ProviderScope(
        overrides: [
          creatorNetworkServiceProvider.overrideWithValue(fake),
          creatorApplicantProvider.overrideWith((ref) async =>
              const CreatorApplicant(name: 'Ana Souza', username: 'ana')),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.dark(),
          locale: const Locale('pt'),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.supportedLocales,
        ),
      ));
      await tester.pumpAndSettle();
      return fake;
    }

    Future<void> fillAll(WidgetTester tester) async {
      // Etapa 1: nada selecionado -> Continuar desabilitado.
      FilledButton cta() => tester.widget<FilledButton>(find.byType(FilledButton));
      expect(cta().onPressed, isNull);
      await tester.tap(find.byKey(const ValueKey('niche_games')));
      await tester.pump();
      // País vem da região do aparelho; garante seleção para o teste.
      if (cta().onPressed == null) {
        await tester.tap(find.byKey(const ValueKey('field_country')));
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining('Brasil').first);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      // Etapa 2
      expect(cta().onPressed, isNull);
      await tester.enterText(find.byKey(const ValueKey('field_handle')), '@ana.lives');
      await tester.enterText(find.byKey(const ValueKey('field_followers')), '1200');
      await tester.pump();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      // Etapa 3
      expect(cta().onPressed, isNull);
      await tester.enterText(find.byKey(const ValueKey('field_motivation')),
          'Quero crescer minha comunidade com lives toda semana.');
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(cta().onPressed, isNotNull);
    }

    testWidgets('sucesso: envia e mostra a tela de inscrição enviada',
        (tester) async {
      final fake = await pumpForm(tester, _FakeService());
      await fillAll(tester);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('SUBMITTED_OK'), findsOneWidget);
      expect(fake.submitCalls, 1);
      expect(fake.sentBody!['social_links'], {'instagram': 'ana.lives'});
      expect(fake.sentBody!.containsKey('email'), isFalse);
    });

    testWidgets(
        'timeout depois de salvar no servidor: mostra sucesso, não erro',
        (tester) async {
      await pumpForm(
        tester,
        _FakeService(
          savedAfterFailure: true,
          failWith: DioException(
            requestOptions: RequestOptions(path: '/creator/applications'),
            type: DioExceptionType.receiveTimeout,
          ),
        ),
      );
      await fillAll(tester);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('SUBMITTED_OK'), findsOneWidget);
    });

    testWidgets('falha real (nada salvo): mostra erro e continua no form',
        (tester) async {
      await pumpForm(
        tester,
        _FakeService(
          failWith: DioException(
            requestOptions: RequestOptions(path: '/creator/applications'),
            type: DioExceptionType.connectionError,
          ),
        ),
      );
      await fillAll(tester);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('SUBMITTED_OK'), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('409 leva ao acompanhamento', (tester) async {
      final fake = await pumpForm(
        tester,
        _FakeService(
          failWith: DioException(
            requestOptions: RequestOptions(path: '/creator/applications'),
            response: Response(
              requestOptions: RequestOptions(path: '/creator/applications'),
              statusCode: 409,
              data: {'detail': 'creator_application_already_active'},
            ),
            type: DioExceptionType.badResponse,
          ),
        ),
      );
      await fillAll(tester);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('STATUS'), findsOneWidget);
      expect(fake.submitCalls, 1);
    });

    testWidgets('não pede nome, e-mail, telefone, cidade nem tem "(opcional)"',
        (tester) async {
      await pumpForm(tester, _FakeService());
      for (final t in ['Nome completo', 'E-mail', 'Telefone', 'Cidade', 'opcional']) {
        expect(find.textContaining(t), findsNothing, reason: t);
      }
      expect(find.text('Ana Souza  @ana'), findsOneWidget);
    });
  });
}
