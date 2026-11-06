import 'package:brawe_app/data/repositories/auth_repository.dart';
import 'package:brawe_app/data/services/auth_service.dart';
import 'package:brawe_app/data/services/storage_service.dart';
import 'package:brawe_app/domain/models/user.dart';
import 'package:brawe_app/ui/auth/view_models/login_view_model.dart';
import 'package:brawe_app/ui/auth/widgets/step_up_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../settings/security_test_support.dart';

class _Auth extends AuthService {
  _Auth() : super(Dio());
  Object? stepUpError;
  final codes = <String>[];
  int logins = 0;
  final resends = <String>[];
  Object? resendError;
  @override
  Future<int> loginStepUpResend(String id) async {
    resends.add(id);
    if (resendError != null) throw resendError!;
    return 45;
  }

  @override
  Future<Map<String, dynamic>> loginStepUp(String id, String code) async {
    codes.add('$id:$code');
    if (stepUpError != null) throw stepUpError!;
    return {
      'access_token': 't',
      'user': {
        'id': 'u1',
        'email': 'j@x.com',
        'name': 'J',
        'user_type': 'affiliate',
        'display_id': 'B-1',
        'first_name': 'J',
        'last_name': 'D',
        'created_at': '2026-03-10T00:00:00Z',
      },
    };
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    logins++;
    throw DioException(
      requestOptions: RequestOptions(path: '/auth/login'),
      response: Response(
        requestOptions: RequestOptions(path: '/auth/login'),
        statusCode: 403,
        data: {
          'detail': {
            'code': 'step_up_required',
            'challenge_id': 'c-new',
            'email_masked': 'j***@gmail.com',
          },
        },
      ),
    );
  }
}

class _Store extends StorageService {
  _Store() : super(const FlutterSecureStorage());
  @override
  Future<void> saveToken(String t) async {}
  @override
  Future<void> saveUser(User u) async {}
}

DioException _http(int status, Object data) => DioException(
  requestOptions: RequestOptions(path: '/auth/login/step-up'),
  response: Response(
    requestOptions: RequestOptions(path: '/auth/login/step-up'),
    statusCode: status,
    data: data,
  ),
);

Future<User?> _pump(WidgetTester t, _Auth auth, {GlobalKey? key, bool dark = false, double w = 390, double scale = 1}) async {
  setScreen(t, w, 844);
  User? result;
  await t.pumpWidget(
    securityApp(
      boundaryKey: key,
      dark: dark,
      textScale: scale,
      overrides: [authRepositoryProvider.overrideWithValue(AuthRepository(auth, _Store()))],
      home: Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async {
                result = await Navigator.of(ctx).push<User>(
                  MaterialPageRoute(
                    builder: (_) => const StepUpScreen(
                      challenge: StepUpChallenge(
                        challengeId: 'c1',
                        emailMasked: 'j***@gmail.com',
                      ),
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await t.tap(find.text('open'));
  await t.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('mostra o e-mail mascarado e valida o código', (t) async {
    final auth = _Auth();
    await _pump(t, auth);
    expect(find.textContaining('j***@gmail.com'), findsOneWidget);
    await t.enterText(find.byKey(const Key('stepup-field')), '123456');
    await t.pumpAndSettle();
    expect(auth.codes, ['c1:123456']);
    // voltou ao login (pop com o usuário)
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('código errado mostra tentativas restantes', (t) async {
    final auth = _Auth()
      ..stepUpError = _http(400, {'detail': 'invalid_code', 'remaining_attempts': 2});
    await _pump(t, auth);
    await t.enterText(find.byKey(const Key('stepup-field')), '000000');
    await t.pumpAndSettle();
    expect(find.byKey(const Key('stepup-error')), findsOneWidget);
    expect(find.textContaining('2'), findsWidgets);
  });

  testWidgets('429 de tentativas esgotadas (sem retry_after) usa a mensagem de código', (t) async {
    final auth = _Auth()..stepUpError = _http(429, {'detail': 'too_many_attempts'});
    await _pump(t, auth);
    await t.enterText(find.byKey(const Key('stepup-field')), '000000');
    await t.pumpAndSettle();
    expect(find.byKey(const Key('stepup-error')), findsOneWidget);
  });

  testWidgets('429 mostra contagem', (t) async {
    final auth = _Auth()
      ..stepUpError = _http(429, {'code': 'too_many_attempts', 'retry_after': 120});
    await _pump(t, auth);
    await t.enterText(find.byKey(const Key('stepup-field')), '000000');
    await t.pumpAndSettle();
    expect(find.textContaining('2 min'), findsOneWidget);
  });

  testWidgets('reenviar só depois da contagem; usa a rota de reenvio do step-up', (t) async {
    final auth = _Auth();
    await _pump(t, auth);
    expect(find.textContaining('Reenviar em'), findsOneWidget);
    var btn = t.widget<TextButton>(find.byKey(const Key('stepup-resend')));
    expect(btn.onPressed, isNull);
    await t.pump(const Duration(seconds: 61));
    expect(find.text('Reenviar código'), findsOneWidget);
    await t.tap(find.byKey(const Key('stepup-resend')));
    await t.pumpAndSettle();
    expect(auth.logins, 0); // não repete o login com senha
    expect(auth.resends, ['c1']);
    expect(find.textContaining('Reenviar em'), findsOneWidget);
    expect(find.textContaining('45'), findsWidgets); // resend_in do servidor
    await t.enterText(find.byKey(const Key('stepup-field')), '654321');
    await t.pumpAndSettle();
    expect(auth.codes.last, 'c1:654321'); // mesmo desafio
  });

  for (final w in [320.0, 390.0, 412.0]) {
    for (final dark in [false, true]) {
      testWidgets('layout ${w.toInt()} ${dark ? 'dark' : 'light'} 200%', (t) async {
        await _pump(t, _Auth(), w: w, dark: dark, scale: 2);
        expect(t.takeException(), isNull);
      });
    }
  }
}
