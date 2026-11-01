import 'package:brawe_app/domain/models/combo_tier.dart';
import 'package:brawe_app/domain/models/gift_presentation.dart';
import 'package:brawe_app/domain/models/live_gift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComboMath.crossedTier', () {
    const ats = [10, 50, 100];
    test('cruza um degrau', () {
      expect(ComboMath.crossedTier(ats, 8, 10), 10);
      expect(ComboMath.crossedTier(ats, 9, 12), 10);
    });
    test('não cruza de novo o que já passou', () {
      expect(ComboMath.crossedTier(ats, 10, 11), isNull);
      expect(ComboMath.crossedTier(ats, 0, 9), isNull);
    });
    test('vários degraus na mesma chamada: só o maior', () {
      expect(ComboMath.crossedTier(ats, 5, 60), 50);
      expect(ComboMath.crossedTier(ats, 0, 500), 100);
    });
    test('nextTier', () {
      expect(ComboMath.nextTier(ats, 0), 10);
      expect(ComboMath.nextTier(ats, 10), 50);
      expect(ComboMath.nextTier(ats, 100), isNull);
    });
  });

  group('combo progress', () {
    test('texto', () {
      expect(ComboMath.progressText(37, 50), '×37 · faltam 13');
      expect(ComboMath.progressText(49, 50), '×49 · falta 1');
      expect(ComboMath.progressText(120, null), '×120');
      expect(ComboMath.progressText(50, 50), '×50');
    });
    test('fração parte do degrau anterior', () {
      expect(ComboMath.progress(30, 50, prevAt: 10), 0.5);
      expect(ComboMath.progress(5, 10), 0.5);
      expect(ComboMath.progress(99, 50, prevAt: 10), 1.0);
      expect(ComboMath.progress(10, 50, prevAt: 10), 0.0);
    });
    test('contagem: servidor quando presente', () {
      expect(ComboMath.displayCount(serverCount: 37, localCount: 5), 37);
      expect(ComboMath.displayCount(serverCount: null, localCount: 5), 5);
      expect(ComboMath.displayCount(serverCount: 0, localCount: 5), 5);
    });
  });

  group('ParticlePreset', () {
    test('os 8 presets', () {
      for (final n in const [
        'petals', 'hearts', 'confetti', 'sparks',
        'stars', 'coins', 'bubbles', 'embers',
      ]) {
        expect(ParticlePreset.parse(n)?.name, n);
      }
      expect(ParticlePreset.values.length, 8);
    });
    test('desconhecido vira null', () {
      expect(ParticlePreset.parse('glitter'), isNull);
      expect(ParticlePreset.parse(null), isNull);
      expect(ParticlePreset.parse(3), isNull);
      expect(ParticlePreset.parse(' Petals '), ParticlePreset.petals);
    });
  });

  group('ComboTierEvent', () {
    Map<String, dynamic> payload({Map<String, dynamic>? tier}) => {
      'room_id': 'r1',
      'sender_id': 'u1',
      'sender_name': 'Ana',
      'gift_slug': 'rose',
      'gift_name': 'Rosa',
      'count': 52,
      'at': 50,
      'next_at': 100,
      'tier': tier ?? {'effect_type': 'particles', 'particles': 'petals', 'haptic': 'medium'},
    };

    test('partículas com padrão do contrato', () {
      final e = ComboTierEvent.tryParse(payload())!;
      expect(e.at, 50);
      expect(e.nextAt, 100);
      expect(e.comboKey, 'u1::rose');
      expect(e.tier.preset, ParticlePreset.petals);
      final pr = e.tier.resolvedPresentation;
      expect(pr.layer, GiftLayer.underChat);
      expect(pr.position, GiftPosition.full);
      expect(pr.backdrop, GiftBackdrop.none);
      expect(pr.holdMs, 2500);
      expect(pr.haptic, GiftHaptic.medium);
    });

    test('lottie usa o padrão center_large e a receita do servidor', () {
      final e = ComboTierEvent.tryParse(payload(tier: {
        'effect_type': 'lottie',
        'effect_url': '/cdn/x.json',
        'presentation': {'scale': 0.5},
        'announce': true,
      }))!;
      expect(e.tier.announce, isTrue);
      final pr = e.tier.resolvedPresentation;
      expect(pr.layer, GiftLayer.overChat);
      expect(pr.scale, 0.5);
    });

    test('payload inválido não lança', () {
      expect(ComboTierEvent.tryParse(payload(tier: {'effect_type': 'particles'})), isNull);
      expect(ComboTierEvent.tryParse(payload(tier: {'effect_type': 'vap'})), isNull);
      expect(ComboTierEvent.tryParse(payload(tier: {'effect_type': 'x'})), isNull);
      expect(ComboTierEvent.tryParse({'at': 'abc', 'tier': 3}), isNull);
    });

    test('sem next_at', () {
      final p = payload()..['next_at'] = null;
      expect(ComboTierEvent.tryParse(p)!.nextAt, isNull);
    });
  });

  test('LiveGift tolera ausência de combo_count', () {
    final g = LiveGift(
      id: '1', senderId: 's', senderName: 'n', giftId: 'g',
      giftName: 'Rosa', quantity: 1, timestamp: DateTime(2026),
    );
    expect(g.comboCount, isNull);
    expect(g.comboNextAt, isNull);
  });
}
