import 'package:brawe_app/data/repositories/auth_repository.dart';
import 'package:brawe_app/data/services/auth_service.dart';
import 'package:brawe_app/data/services/storage_service.dart';
import 'package:brawe_app/domain/models/failure.dart';
import 'package:brawe_app/domain/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

Response _res(int status, Object? data, {Map<String, List<String>>? headers}) =>
    Response(
      requestOptions: RequestOptions(path: '/auth/login'),
      statusCode: status,
      data: data,
      headers: Headers.fromMap(headers ?? {}),
    );

class _Auth extends AuthService {
  _Auth() : super(Dio());
  Object? loginError;
  int stepUpCalls = 0;
  String? lastChallenge;
  String? lastCode;
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (loginError != null) throw loginError!;
    return {};
  }

  @override
  Future<Map<String, dynamic>> loginStepUp(String id, String code) async {
    stepUpCalls++;
    lastChallenge = id;
    lastCode = code;
    return {
      'access_token': 'new-token',
      'session_id': 's1',
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
}

class _Store extends StorageService {
  _Store() : super(const FlutterSecureStorage());
  String? token;
  @override
  Future<void> saveToken(String t) async => token = t;
  @override
  Future<void> saveUser(User u) async {}
}

DioException _err(int status, Object? data, {Map<String, List<String>>? h}) =>
    DioException(
      requestOptions: RequestOptions(path: '/auth/login'),
      response: _res(status, data, headers: h),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('403 do core traz resend_in/expires_in', () {
    final e = StepUpRequiredException.fromResponse(_res(403, {
      'detail': 'step_up_required',
      'code': 'step_up_required',
      'challenge_id': 'c9',
      'email_masked': 'a***@x.com',
      'expires_in': 600,
      'resend_in': 60,
    }));
    expect(e!.resendIn, 60);
    expect(e.expiresIn, 600);
  });

  test('403 step_up_required dentro de detail', () {
    final e = StepUpRequiredException.fromResponse(
      _res(403, {
        'detail': {
          'code': 'step_up_required',
          'challenge_id': 'c1',
          'email_masked': 'j***@gmail.com',
        },
      }),
    )!;
    expect(e.challengeId, 'c1');
    expect(e.emailMasked, 'j***@gmail.com');
  });

  test('403 step_up_required no topo', () {
    final e = StepUpRequiredException.fromResponse(
      _res(403, {
        'code': 'step_up_required',
        'challenge_id': 'c2',
        'email_masked': 'a***@x.com',
      }),
    )!;
    expect(e.challengeId, 'c2');
  });

  test('outros 403 (suspensão) e 401 não são step-up', () {
    expect(
      StepUpRequiredException.fromResponse(
        _res(403, {'detail': {'code': 'account_suspended'}}),
      ),
      isNull,
    );
    expect(StepUpRequiredException.fromResponse(_res(401, {})), isNull);
  });

  test('login arriscado lança StepUpRequiredException', () async {
    final auth = _Auth()
      ..loginError = _err(403, {
        'detail': {
          'code': 'step_up_required',
          'challenge_id': 'c1',
          'email_masked': 'j***@gmail.com',
        },
      });
    final repo = AuthRepository(auth, _Store());
    expect(
      repo.login('j@x.com', 'secret1'),
      throwsA(isA<StepUpRequiredException>()),
    );
  });

  test('step-up troca o código pela sessão e guarda o token novo', () async {
    final store = _Store();
    final auth = _Auth();
    final user = await AuthRepository(auth, store).stepUp('c1', '123456');
    expect(auth.lastChallenge, 'c1');
    expect(auth.lastCode, '123456');
    expect(store.token, 'new-token');
    expect(user.email, 'j@x.com');
  });

  test('429 mostra a contagem (retry_after)', () async {
    final auth = _Auth()
      ..loginError = _err(429, {'code': 'too_many_attempts', 'retry_after': 45});
    try {
      await AuthRepository(auth, _Store()).login('j@x.com', 'secret1');
      fail('deveria lançar');
    } on Failure catch (f) {
      expect(f.toDisplayMessage(), contains('45 s'));
    }
    expect(tooManyAttemptsMessage(300), contains('5 min'));
    expect(tooManyAttemptsMessage(null), contains('instantes'));
    expect(
      retryAfterSeconds(_res(429, {'detail': {'retry_after': 30}})),
      30,
    );
  });
}
