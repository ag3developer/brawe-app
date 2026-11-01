import 'package:brawe_app/core/remote_config/remote_config_service.dart';
import 'package:brawe_app/core/remote_config/remote_flags.dart';
import 'package:brawe_app/ui/live/shared/widgets/overlays/combo_tier_queue.dart';
import 'package:brawe_app/ui/live/shared/widgets/overlays/entrance_effect_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => RemoteFlags.notifier.value = RemoteFlags.defaults);

  test('defaults match the contract', () {
    const f = RemoteFlags.defaults;
    expect(f.chatPaceSlowMs, 320);
    expect(f.chatPaceMidMs, 190);
    expect(f.chatPaceFastMs, 120);
    expect(f.chatMaxPending, 24);
    expect(f.chatMyHoldMs, 1400);
    expect(f.entranceStaleS, 8);
    expect(f.comboTierStaleS, 6);
    expect(f.videoRetryMaxS, 6);
    expect(f.featureEvents && f.featureCombos && f.featureAwards, isTrue);
    expect(RemoteFlags.fromMap(const {}), RemoteFlags.defaults);
  });

  test('defaultValues map covers every key used by fromMap', () {
    expect(RemoteFlags.fromMap(RemoteFlags.defaultValues), RemoteFlags.defaults);
    expect(RemoteFlags.defaultValues.length, 11);
  });

  test('valid values override, loose types are accepted', () {
    final f = RemoteFlags.fromMap({
      'chat_pace_slow_ms': 500,
      'chat_pace_mid_ms': '250',
      'chat_max_pending': 40.0,
      'feature_events': false,
      'feature_combos': 'false',
      'feature_awards': '0',
    });
    expect(f.chatPaceSlowMs, 500);
    expect(f.chatPaceMidMs, 250);
    expect(f.chatMaxPending, 40);
    expect(f.featureEvents, isFalse);
    expect(f.featureCombos, isFalse);
    expect(f.featureAwards, isFalse);
    expect(f.chatPaceFastMs, 120); // ausente -> padrão
  });

  test('garbage and out-of-range values fall back to the default', () {
    final f = RemoteFlags.fromMap({
      'chat_pace_slow_ms': 'abc',
      'chat_pace_mid_ms': -5,
      'chat_pace_fast_ms': 99999999,
      'chat_max_pending': 0,
      'entrance_stale_s': null,
      'feature_events': 'maybe',
    });
    expect(f, RemoteFlags.defaults);
  });

  test('init tolerates Firebase being unavailable', () async {
    await RemoteConfigService.init(); // sem Firebase.initializeApp
    expect(RemoteFlags.current, RemoteFlags.defaults);
  });

  test('queues take stale times from the flags', () {
    RemoteFlags.notifier.value = const RemoteFlags(
      entranceStaleS: 3,
      comboTierStaleS: 2,
    );
    expect(EntranceEffectQueue().maxAge, const Duration(seconds: 3));
    expect(ComboTierQueue().maxAge, const Duration(seconds: 2));
    expect(
      ComboTierQueue(maxAge: const Duration(seconds: 9)).maxAge,
      const Duration(seconds: 9),
    );
  });
}
