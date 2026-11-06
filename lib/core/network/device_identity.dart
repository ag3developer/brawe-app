import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';

/// Identidade do aparelho enviada em TODA requisição do app:
/// `X-Device-Id` (UUID v4 gerado uma vez e guardado no armazenamento seguro),
/// `X-Device-Name`, `X-Device-Platform` e `X-App-Version`. O servidor usa
/// isso para listar "Aparelhos conectados" e avisar de acessos novos.
class DeviceIdentity {
  DeviceIdentity({
    FlutterSecureStorage? storage,
    String? platform,
    String? osVersion,
    Future<String> Function()? appVersionLoader,
    Future<String> Function()? deviceNameLoader,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _platform = platform ?? (Platform.isIOS ? 'ios' : 'android'),
       _osVersion = osVersion ?? Platform.operatingSystemVersion,
       _appVersionLoader = appVersionLoader ?? _loadAppVersion,
       _deviceNameLoader = deviceNameLoader;

  /// Instância compartilhada pelos clientes Dio.
  static final DeviceIdentity instance = DeviceIdentity();

  final FlutterSecureStorage _storage;
  final String _platform;
  final String _osVersion;
  final Future<String> Function() _appVersionLoader;
  final Future<String> Function()? _deviceNameLoader;

  Future<Map<String, String>>? _headers;
  String? _id;

  static Future<String> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  /// UUID v4 estável do aparelho (sobrevive ao logout).
  Future<String> deviceId() async {
    final cached = _id;
    if (cached != null) return cached;
    String? stored;
    try {
      stored = await _storage.read(key: AppConstants.deviceIdKey);
    } catch (_) {
      stored = null;
    }
    if (stored == null || stored.trim().isEmpty) {
      stored = const Uuid().v4();
      try {
        await _storage.write(key: AppConstants.deviceIdKey, value: stored);
      } catch (_) {
        // sem persistência: vale para esta execução.
      }
    }
    return _id = stored.trim();
  }

  /// Nome genérico (sem consultar o aparelho): "iOS 17.5.1" / "Android".
  /// No Android `operatingSystemVersion` é a versão do kernel Linux, então não entra.
  String deviceName() {
    if (_platform != 'ios') return 'Android';
    const os = 'iOS';
    final m = RegExp(r'\d+(\.\d+)*').firstMatch(_osVersion);
    return m == null ? os : '$os ${m.group(0)}';
  }

  /// Nome real do aparelho via `device_info_plus` ("iPhone 15 Pro (iOS 17.5.1)",
  /// "Samsung SM-S918B (Android 14)"). Qualquer falha cai em [deviceName].
  Future<String> resolveDeviceName() async {
    try {
      final loader = _deviceNameLoader ?? _loadDeviceName;
      final name = (await loader()).trim();
      if (name.isNotEmpty) return name.length > 120 ? name.substring(0, 120) : name;
    } catch (_) {
      // plugin indisponível (teste, simulador exótico): usa o nome genérico.
    }
    return deviceName();
  }

  Future<String> _loadDeviceName() async {
    final plugin = DeviceInfoPlugin();
    if (_platform == 'ios') {
      final info = await plugin.iosInfo;
      return formatIosDeviceName(info.utsname.machine, info.systemVersion);
    }
    final info = await plugin.androidInfo;
    return formatAndroidDeviceName(
      info.manufacturer,
      info.model,
      info.version.release,
    );
  }

  /// `utsname.machine` → nome comercial (iPhone 11 a 17). Desconhecido: o
  /// identificador cru (ex.: "iPhone16,1"), que ainda identifica o modelo.
  static String iosMarketingName(String machine) =>
      _iphoneNames[machine] ?? machine;

  static String formatIosDeviceName(String machine, String systemVersion) {
    final model = iosMarketingName(machine.trim());
    final v = systemVersion.trim();
    if (model.isEmpty) return v.isEmpty ? 'iOS' : 'iOS $v';
    return v.isEmpty ? model : '$model (iOS $v)';
  }

  /// "Samsung SM-S918B (Android 14)". Não repete o fabricante se o modelo já o traz.
  static String formatAndroidDeviceName(
    String manufacturer,
    String model,
    String release,
  ) {
    final man = manufacturer.trim();
    final mod = model.trim();
    final maker = man.isEmpty ? '' : man[0].toUpperCase() + man.substring(1);
    var name = mod.toLowerCase().startsWith(man.toLowerCase()) && man.isNotEmpty
        ? mod
        : [maker, mod].where((e) => e.isNotEmpty).join(' ');
    if (name.isEmpty) name = 'Android';
    final v = release.trim();
    return v.isEmpty ? name : '$name (Android $v)';
  }

  static const Map<String, String> _iphoneNames = {
    'iPhone12,1': 'iPhone 11',
    'iPhone12,3': 'iPhone 11 Pro',
    'iPhone12,5': 'iPhone 11 Pro Max',
    'iPhone12,8': 'iPhone SE (2nd gen)',
    'iPhone13,1': 'iPhone 12 mini',
    'iPhone13,2': 'iPhone 12',
    'iPhone13,3': 'iPhone 12 Pro',
    'iPhone13,4': 'iPhone 12 Pro Max',
    'iPhone14,4': 'iPhone 13 mini',
    'iPhone14,5': 'iPhone 13',
    'iPhone14,2': 'iPhone 13 Pro',
    'iPhone14,3': 'iPhone 13 Pro Max',
    'iPhone14,6': 'iPhone SE (3rd gen)',
    'iPhone14,7': 'iPhone 14',
    'iPhone14,8': 'iPhone 14 Plus',
    'iPhone15,2': 'iPhone 14 Pro',
    'iPhone15,3': 'iPhone 14 Pro Max',
    'iPhone15,4': 'iPhone 15',
    'iPhone15,5': 'iPhone 15 Plus',
    'iPhone16,1': 'iPhone 15 Pro',
    'iPhone16,2': 'iPhone 15 Pro Max',
    'iPhone17,3': 'iPhone 16',
    'iPhone17,4': 'iPhone 16 Plus',
    'iPhone17,1': 'iPhone 16 Pro',
    'iPhone17,2': 'iPhone 16 Pro Max',
    'iPhone17,5': 'iPhone 16e',
    'iPhone18,3': 'iPhone 17',
    'iPhone18,1': 'iPhone 17 Pro',
    'iPhone18,2': 'iPhone 17 Pro Max',
    'iPhone18,4': 'iPhone Air',
  };

  /// Os quatro cabeçalhos (calculados uma vez e reaproveitados).
  Future<Map<String, String>> headers() {
    return _headers ??= () async {
      String version;
      try {
        version = await _appVersionLoader();
      } catch (_) {
        version = '0.0.0';
      }
      return {
        'X-Device-Id': await deviceId(),
        'X-Device-Name': await resolveDeviceName(),
        'X-Device-Platform': _platform,
        'X-App-Version': version,
      };
    }();
  }

  /// Interceptor para os clientes Dio (core e Connect).
  Interceptor interceptor() => InterceptorsWrapper(
    onRequest: (options, handler) async {
      try {
        options.headers.addAll(await headers());
      } catch (_) {
        // nunca bloqueia a requisição por causa dos cabeçalhos.
      }
      handler.next(options);
    },
  );
}
