import 'package:brawe_app/core/constants/app_constants.dart';
import 'package:brawe_app/core/network/device_identity.dart';
import 'package:brawe_app/core/network/session_ended.dart';
import 'package:brawe_app/data/services/storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _Capture implements HttpClientAdapter {
  RequestOptions? last;
  int status = 200;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString('{}', status, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

DeviceIdentity _identity(FlutterSecureStorage st) => DeviceIdentity(
  storage: st,
  platform: 'ios',
  osVersion: 'Version 17.5.1 (Build 21F90)',
  appVersionLoader: () async => '1.0.46',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('envia os quatro cabeçalhos em toda requisição', () async {
    final adapter = _Capture();
    final dio = Dio()..httpClientAdapter = adapter;
    dio.interceptors.add(_identity(const FlutterSecureStorage()).interceptor());
    await dio.get('https://x.test/a');
    final h = adapter.last!.headers;
    expect(h['X-Device-Id'], matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(h['X-Device-Name'], 'iOS 17.5.1'); // sem plugin no teste: nome genérico
    expect(h['X-Device-Platform'], 'ios');
    expect(h['X-App-Version'], '1.0.46');
  });

  test('device id é UUID v4 gerado uma vez e persistido', () async {
    const st = FlutterSecureStorage();
    final a = await _identity(st).deviceId();
    expect(a[14], '4'); // versão 4
    // outra instância (novo processo) lê o mesmo valor.
    final b = await _identity(st).deviceId();
    expect(b, a);
    expect(await st.read(key: AppConstants.deviceIdKey), a);
  });

  test('logout (clearAll) preserva o device id', () async {
    const st = FlutterSecureStorage();
    final id = await _identity(st).deviceId();
    final storage = StorageService(st);
    await storage.saveToken('abc');
    await storage.clearAll();
    expect(await storage.getToken(), isNull);
    expect(await _identity(st).deviceId(), id);
  });

  test('Android: nome "Android" (a versão do SO não é confiável)', () async {
    final i = DeviceIdentity(
      storage: const FlutterSecureStorage(),
      platform: 'android',
      osVersion: 'Linux 5.15 Android 14',
      appVersionLoader: () async => '1.0.46',
    );
    expect(i.deviceName(), 'Android');
    expect((await i.headers())['X-Device-Platform'], 'android');
  });

  test('nome real do aparelho via loader injetado', () async {
    final i = DeviceIdentity(
      storage: const FlutterSecureStorage(),
      platform: 'ios',
      appVersionLoader: () async => '1.0.46',
      deviceNameLoader: () async =>
          DeviceIdentity.formatIosDeviceName('iPhone16,1', '17.5.1'),
    );
    expect((await i.headers())['X-Device-Name'], 'iPhone 15 Pro (iOS 17.5.1)');
  });

  test('falha do loader cai no nome genérico', () async {
    final i = DeviceIdentity(
      storage: const FlutterSecureStorage(),
      platform: 'ios',
      osVersion: 'Version 17.5.1 (Build 21F90)',
      appVersionLoader: () async => '1.0.46',
      deviceNameLoader: () async => throw Exception('sem plugin'),
    );
    expect(await i.resolveDeviceName(), 'iOS 17.5.1');
  });

  test('iOS: tabela iPhone 11-17 e fallback para o identificador cru', () {
    const cases = {
      'iPhone12,1': 'iPhone 11',
      'iPhone13,2': 'iPhone 12',
      'iPhone14,5': 'iPhone 13',
      'iPhone15,2': 'iPhone 14 Pro',
      'iPhone15,5': 'iPhone 15 Plus',
      'iPhone17,3': 'iPhone 16',
      'iPhone17,2': 'iPhone 16 Pro Max',
      'iPhone18,3': 'iPhone 17',
      'iPhone18,4': 'iPhone Air',
    };
    cases.forEach((id, name) {
      expect(DeviceIdentity.iosMarketingName(id), name);
    });
    expect(DeviceIdentity.iosMarketingName('iPhone99,9'), 'iPhone99,9');
    expect(
      DeviceIdentity.formatIosDeviceName('iPhone99,9', '26.0'),
      'iPhone99,9 (iOS 26.0)',
    );
    expect(DeviceIdentity.formatIosDeviceName('iPhone12,1', ''), 'iPhone 11');
  });

  test('Android: fabricante + modelo + versão', () {
    expect(
      DeviceIdentity.formatAndroidDeviceName('samsung', 'SM-S918B', '14'),
      'Samsung SM-S918B (Android 14)',
    );
    expect(
      DeviceIdentity.formatAndroidDeviceName('Google', 'Pixel 8', '15'),
      'Google Pixel 8 (Android 15)',
    );
    expect(
      DeviceIdentity.formatAndroidDeviceName('HUAWEI', 'HUAWEI P30', ''),
      'HUAWEI P30',
    );
  });

  group('SessionEnded', () {
    Future<_Capture> run(int status, String path, {String? sentToken}) async {
      FlutterSecureStorage.setMockInitialValues({'auth_token': 'tok'});
      final adapter = _Capture()..status = status;
      final dio = Dio()..httpClientAdapter = adapter;
      dio.interceptors.add(
        SessionEnded.interceptor(StorageService(const FlutterSecureStorage())),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            if (sentToken != null) o.headers['Authorization'] = 'Bearer $sentToken';
            h.next(o);
          },
        ),
      );
      try {
        await dio.get('https://x.test$path');
      } catch (_) {}
      return adapter;
    }

    setUp(() {
      SessionEnded.instance.takeMessage();
      SessionEnded.instance.handled();
    });

    test('401 autenticado dispara o aviso', () async {
      await run(401, '/auth/sessions', sentToken: 'tok');
      expect(SessionEnded.instance.messagePending, isTrue);
    });

    test('401 de login/senha errada não dispara', () async {
      await run(401, '/auth/login', sentToken: 'tok');
      await run(401, '/auth/me/password', sentToken: 'tok');
      expect(SessionEnded.instance.messagePending, isFalse);
    });

    test('token antigo (já trocado) não derruba a sessão nova', () async {
      await run(401, '/auth/sessions', sentToken: 'velho');
      expect(SessionEnded.instance.messagePending, isFalse);
    });

    test('sem token enviado não dispara; repetição não entra em laço', () async {
      await run(401, '/feed');
      expect(SessionEnded.instance.messagePending, isFalse);
      var calls = 0;
      SessionEnded.instance.addListener(() => calls++);
      SessionEnded.instance.trigger();
      SessionEnded.instance.trigger();
      expect(calls, 1);
    });
  });
}
