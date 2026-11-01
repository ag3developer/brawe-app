import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import 'remote_flags.dart';

/// Busca o Remote Config sem bloquear a abertura do app.
///
/// Os padrões ficam no código ([RemoteFlags.defaultValues]); qualquer falha
/// (sem rede, Firebase ausente, throttling) é engolida e os valores
/// anteriores/padrão continuam valendo.
class RemoteConfigService {
  const RemoteConfigService._();

  static const minimumFetchInterval = Duration(hours: 1);

  /// Dispara e esquece: use `unawaited(RemoteConfigService.init())`.
  static Future<void> init({FirebaseRemoteConfig? instance}) async {
    try {
      final rc = instance ?? FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: minimumFetchInterval,
        ),
      );
      await rc.setDefaults(RemoteFlags.defaultValues);
      // Valores já ativados em sessões anteriores valem desde o início.
      _publish(rc);
      await rc.fetchAndActivate();
      _publish(rc);
    } catch (e) {
      debugPrint('RemoteConfig: ignorado ($e)');
    }
  }

  static void _publish(FirebaseRemoteConfig rc) {
    final raw = <String, Object?>{
      for (final k in RemoteFlags.defaultValues.keys) k: _read(rc, k),
    };
    final next = RemoteFlags.fromMap(raw);
    if (next != RemoteFlags.current) RemoteFlags.notifier.value = next;
  }

  static Object? _read(FirebaseRemoteConfig rc, String key) {
    final def = RemoteFlags.defaultValues[key];
    return def is bool ? rc.getBool(key) : rc.getInt(key);
  }
}
