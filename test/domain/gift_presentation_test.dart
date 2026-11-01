import 'package:brawe_app/domain/models/gift_presentation.dart';
import 'package:brawe_app/domain/models/live_gift.dart';
import 'package:brawe_app/ui/live/shared/widgets/overlays/gift_stage.dart';
import 'package:flutter_test/flutter_test.dart';

LiveGift _gift({String? type, String? anim, Map<String, dynamic>? pres}) =>
    LiveGift(
      id: '1',
      senderId: 's',
      senderName: 'n',
      giftId: 'g',
      giftName: 'G',
      quantity: 1,
      timestamp: DateTime(2026),
      displayType: type,
      animationType: anim,
      presentation: pres,
    );

void main() {
  group('defaults (presentation null)', () {
    test('center_large', () {
      final p = _gift(type: 'center_large').resolvedPresentation;
      expect(p.enter, const GiftPhase(GiftTransition.zoom, 450));
      expect(p.exit, const GiftPhase(GiftTransition.fade, 350));
      expect(p.position, GiftPosition.center);
      expect(p.scale, 0.7);
      expect(p.layer, GiftLayer.overChat);
      expect(p.backdrop, GiftBackdrop.none);
      expect(p.haptic, GiftHaptic.medium);
      expect(p.holdMs, isNull);
    });

    test('fullscreen e VAP', () {
      for (final g in [
        _gift(type: 'fullscreen'),
        _gift(type: 'center_large', anim: 'vap'),
      ]) {
        final p = g.resolvedPresentation;
        expect(p.enter, const GiftPhase(GiftTransition.fade, 300));
        expect(p.exit, const GiftPhase(GiftTransition.fade, 400));
        expect(p.position, GiftPosition.full);
        expect(p.backdrop, GiftBackdrop.darken);
        expect(p.backdropOpacity, 0.25);
      }
      expect(_gift(type: 'fullscreen').resolvedPresentation.haptic,
          GiftHaptic.heavy);
    });
  });

  group('parse', () {
    const fb = GiftPresentation.centerLargeDefault;

    test('receita completa', () {
      final p = GiftPresentation.parse({
        'v': 1,
        'enter': {'type': 'rise', 'ms': 600},
        'exit': {'type': 'curtain', 'ms': 200},
        'position': 'bottom',
        'scale': 0.5,
        'layer': 'under_chat',
        'backdrop': 'dawn',
        'backdrop_opacity': 0.6,
        'haptic': 'none',
        'hold_ms': 4000,
      }, fallback: fb);
      expect(p.enter, const GiftPhase(GiftTransition.rise, 600));
      expect(p.exit, const GiftPhase(GiftTransition.curtain, 200));
      expect(p.position, GiftPosition.bottom);
      expect(p.layer, GiftLayer.underChat);
      expect(p.backdrop, GiftBackdrop.dawn);
      expect(p.haptic, GiftHaptic.none);
      expect(p.holdMs, 4000);
    });

    test('valores desconhecidos e tipos errados caem no padrão', () {
      final p = GiftPresentation.parse({
        'enter': {'type': 'explode', 'ms': 'abc'},
        'exit': 'x',
        'position': 'diagonal',
        'scale': 'big',
        'layer': 7,
        'backdrop': null,
        'haptic': 'huge',
      }, fallback: fb);
      expect(p, fb);
    });

    test('limita números', () {
      final p = GiftPresentation.parse({
        'enter': {'type': 'fade', 'ms': 99999},
        'exit': {'type': 'fade', 'ms': -5},
        'scale': 9,
        'backdrop_opacity': 5,
        'hold_ms': 10,
      }, fallback: fb);
      expect(p.enter.ms, 2000);
      expect(p.exit.ms, 0);
      expect(p.scale, 1.0);
      expect(p.backdropOpacity, 0.8);
      expect(p.holdMs, 1000);
      expect(
        GiftPresentation.parse({'scale': 0.1, 'hold_ms': 99999}, fallback: fb)
            .scale,
        0.4,
      );
    });

    test('lixo não lança', () {
      for (final raw in [null, 42, 'not json', '[1]', <int>[], '{"scale":"0.9"}']) {
        expect(() => GiftPresentation.parse(raw, fallback: fb), returnsNormally);
      }
      expect(GiftPresentation.parse('{"scale":"0.9"}', fallback: fb).scale, 0.9);
      expect(GiftPresentation.parse(null, fallback: fb), fb);
    });
  });

  group('GiftStageMath', () {
    test('zoom entra de pequeno e opaco 0 para cheio', () {
      final p = GiftPresentation.centerLargeDefault;
      final start = GiftStageMath.giftFx(p, 0);
      final shown = GiftStageMath.giftFx(p, 1);
      final gone = GiftStageMath.giftFx(p, 2);
      expect(start.opacity, 0);
      expect(start.scale, closeTo(0.6, 1e-9));
      expect(shown.opacity, 1);
      expect(shown.scale, 1);
      expect(gone.opacity, 0);
    });

    test('rise vem de baixo, drop de cima', () {
      expect(GiftStageMath.fx(GiftTransition.rise, 0).dy, greaterThan(0));
      expect(GiftStageMath.fx(GiftTransition.drop, 0).dy, lessThan(0));
      expect(GiftStageMath.fx(GiftTransition.slideLeft, 0).dx, lessThan(0));
      expect(GiftStageMath.fx(GiftTransition.slideRight, 0).dx, greaterThan(0));
    });

    test('cinema: barras entram e saem', () {
      const p = GiftPresentation(
        enter: GiftPhase(GiftTransition.curtain, 500),
        exit: GiftPhase(GiftTransition.curtain, 500),
        position: GiftPosition.full,
        scale: 0.8,
        layer: GiftLayer.overChat,
        backdrop: GiftBackdrop.darken,
        backdropOpacity: 0.5,
        haptic: GiftHaptic.heavy,
      );
      expect(GiftStageMath.curtainBars(p, 0), 0);
      expect(GiftStageMath.curtainBars(p, 1), 1);
      expect(GiftStageMath.curtainBars(p, 2), 0);
      expect(GiftStageMath.backdrop(p, 1)[0].a, closeTo(0.5, 0.01));
    });
  });
}
