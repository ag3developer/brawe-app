import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ajustes remotos (Firebase Remote Config) com padrões no código.
///
/// Imutável e tolerante: qualquer chave ausente, de tipo errado ou fora da
/// faixa cai no padrão. Código que não é widget lê [RemoteFlags.current];
/// widgets que precisam reagir a mudanças usam [remoteFlagsProvider].
@immutable
class RemoteFlags {
  const RemoteFlags({
    this.chatPaceSlowMs = 320,
    this.chatPaceMidMs = 190,
    this.chatPaceFastMs = 120,
    this.chatMaxPending = 24,
    this.chatMyHoldMs = 1400,
    this.entranceStaleS = 8,
    this.comboTierStaleS = 6,
    this.videoRetryMaxS = 6,
    this.featureEvents = true,
    this.featureCombos = true,
    this.featureAwards = true,
  });

  final int chatPaceSlowMs;
  final int chatPaceMidMs;
  final int chatPaceFastMs;
  final int chatMaxPending;
  final int chatMyHoldMs;
  final int entranceStaleS;
  final int comboTierStaleS;
  final int videoRetryMaxS;
  final bool featureEvents;
  final bool featureCombos;
  final bool featureAwards;

  static const defaults = RemoteFlags();

  /// Chaves do Remote Config e seus padrões (também usadas em `setDefaults`).
  static const Map<String, Object> defaultValues = {
    'chat_pace_slow_ms': 320,
    'chat_pace_mid_ms': 190,
    'chat_pace_fast_ms': 120,
    'chat_max_pending': 24,
    'chat_my_hold_ms': 1400,
    'entrance_stale_s': 8,
    'combo_tier_stale_s': 6,
    'video_retry_max_s': 6,
    'feature_events': true,
    'feature_combos': true,
    'feature_awards': true,
  };

  /// Valor vigente (atualizado quando o Remote Config é ativado).
  static final ValueNotifier<RemoteFlags> notifier = ValueNotifier(defaults);
  static RemoteFlags get current => notifier.value;

  /// Constrói a partir de um mapa cru (chave -> valor). Tipos frouxos
  /// (`"320"`, `"true"`) são aceitos; inválidos/fora da faixa usam o padrão.
  factory RemoteFlags.fromMap(Map<String, Object?> raw) {
    int i(String k, int min, int max) {
      final d = defaultValues[k]! as int;
      final v = raw[k];
      final n = v is num ? v.toInt() : int.tryParse('${v ?? ''}'.trim());
      if (n == null || n < min || n > max) return d;
      return n;
    }

    bool b(String k) {
      final d = defaultValues[k]! as bool;
      final v = raw[k];
      if (v is bool) return v;
      final s = '${v ?? ''}'.trim().toLowerCase();
      if (s == 'true' || s == '1') return true;
      if (s == 'false' || s == '0') return false;
      return d;
    }

    return RemoteFlags(
      chatPaceSlowMs: i('chat_pace_slow_ms', 20, 5000),
      chatPaceMidMs: i('chat_pace_mid_ms', 20, 5000),
      chatPaceFastMs: i('chat_pace_fast_ms', 20, 5000),
      chatMaxPending: i('chat_max_pending', 1, 500),
      chatMyHoldMs: i('chat_my_hold_ms', 0, 10000),
      entranceStaleS: i('entrance_stale_s', 1, 120),
      comboTierStaleS: i('combo_tier_stale_s', 1, 120),
      videoRetryMaxS: i('video_retry_max_s', 1, 60),
      featureEvents: b('feature_events'),
      featureCombos: b('feature_combos'),
      featureAwards: b('feature_awards'),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RemoteFlags &&
      other.chatPaceSlowMs == chatPaceSlowMs &&
      other.chatPaceMidMs == chatPaceMidMs &&
      other.chatPaceFastMs == chatPaceFastMs &&
      other.chatMaxPending == chatMaxPending &&
      other.chatMyHoldMs == chatMyHoldMs &&
      other.entranceStaleS == entranceStaleS &&
      other.comboTierStaleS == comboTierStaleS &&
      other.videoRetryMaxS == videoRetryMaxS &&
      other.featureEvents == featureEvents &&
      other.featureCombos == featureCombos &&
      other.featureAwards == featureAwards;

  @override
  int get hashCode => Object.hash(
    chatPaceSlowMs,
    chatPaceMidMs,
    chatPaceFastMs,
    chatMaxPending,
    chatMyHoldMs,
    entranceStaleS,
    comboTierStaleS,
    videoRetryMaxS,
    featureEvents,
    featureCombos,
    featureAwards,
  );
}

/// Espelho Riverpod de [RemoteFlags.notifier] para widgets.
final remoteFlagsProvider = Provider<RemoteFlags>((ref) {
  void onChange() => ref.invalidateSelf();
  RemoteFlags.notifier.addListener(onChange);
  ref.onDispose(() => RemoteFlags.notifier.removeListener(onChange));
  return RemoteFlags.notifier.value;
});
