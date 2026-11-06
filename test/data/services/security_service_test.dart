import 'dart:convert';

import 'package:brawe_app/data/services/auth_service.dart';
import 'package:brawe_app/data/services/security_service.dart';
import 'package:brawe_app/data/services/storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final (int, Object?) Function(RequestOptions) respond;
  final calls = <String>[];
  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<List<int>>? r, Future<void>? c) async {
    calls.add('${o.method} ${o.path}');
    final (status, body) = respond(o);
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

class _Store extends StorageService {
  _Store() : super(const FlutterSecureStorage());
  String? token;
  @override
  Future<void> saveToken(String t) async => token = t;
}

void main() {
  test('secure-account substitui o token guardado', () async {
    final store = _Store()..token = 'old';
    final a = _Adapter((_) => (200, {'access_token': 'new', 'session_id': 's', 'must_change_password': true}));
    final svc = SecurityService(Dio(BaseOptions(baseUrl: 'https://x.test'))..httpClientAdapter = a, store);
    final r = await svc.secureAccount();
    expect(a.calls, ['POST /auth/secure-account']);
    expect(store.token, 'new');
    expect(r.mustChange, isTrue);
  });

  test('rotas de sessões e eventos', () async {
    final a = _Adapter((o) => switch (o.path) {
      '/auth/sessions' => (200, {'sessions': [{'id': 's1', 'current': true}], 'geo_attribution': 'IP Geolocation by DB-IP'}),
      '/auth/security-events' => (200, {'items': [], 'total': 0, 'page': 2, 'page_size': 20}),
      '/auth/sessions/cur' => (200, {'revoked': true, 'current': true}),
      '/auth/sessions/revoke-others' => (200, {'revoked': 3}),
      _ => (200, {}),
    });
    final svc = SecurityService(Dio(BaseOptions(baseUrl: 'https://x.test'))..httpClientAdapter = a, _Store());
    final s = await svc.sessions();
    expect(s.sessions.single.current, isTrue);
    expect(s.geoAttribution, 'IP Geolocation by DB-IP');
    final r1 = await svc.revokeSession('abc');
    expect(r1.revoked, isTrue); // corpo vazio: assume revogada
    expect(r1.current, isFalse);
    expect((await svc.revokeSession('cur')).current, isTrue);
    expect(await svc.revokeOthers(), 3);
    await svc.logout();
    final p = await svc.events(page: 2);
    expect(p.page, 2);
    expect(a.calls, [
      'GET /auth/sessions',
      'DELETE /auth/sessions/abc',
      'DELETE /auth/sessions/cur',
      'POST /auth/sessions/revoke-others',
      'POST /auth/logout',
      'GET /auth/security-events',
    ]);
  });

  test('404 vira SecurityException.unavailable', () async {
    final a = _Adapter((_) => (404, {'detail': 'Not Found'}));
    final svc = SecurityService(Dio(BaseOptions(baseUrl: 'https://x.test'))..httpClientAdapter = a, _Store());
    expect(
      svc.sessions(),
      throwsA(isA<SecurityException>().having((e) => e.kind, 'kind', SecurityErrorKind.unavailable)),
    );
  });

  test('trocar senha devolve o access_token novo', () async {
    final a = _Adapter((_) => (200, {'access_token': 'fresh'}));
    final auth = AuthService(Dio(BaseOptions(baseUrl: 'https://x.test'))..httpClientAdapter = a);
    expect(await auth.changePassword(currentPassword: 'a', newPassword: 'bbbbbbbb'), 'fresh');
    final b = _Adapter((_) => (200, {'ok': true}));
    final auth2 = AuthService(Dio(BaseOptions(baseUrl: 'https://x.test'))..httpClientAdapter = b);
    expect(await auth2.changePassword(currentPassword: 'a', newPassword: 'bbbbbbbb'), isNull);
  });
}
