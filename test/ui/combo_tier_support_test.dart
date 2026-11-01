import 'dart:io';

import 'package:brawe_app/data/services/sfx_player.dart';
import 'package:brawe_app/domain/models/combo_tier.dart';
import 'package:brawe_app/ui/live/shared/widgets/fx/particle_field.dart';
import 'package:brawe_app/ui/live/shared/widgets/overlays/combo_tier_queue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ComboTierEvent ev(int at, {String sender = 'u1'}) => ComboTierEvent(
  roomId: 'r',
  senderId: sender,
  senderName: 'n',
  giftSlug: 'rose',
  count: at,
  at: at,
  tier: const ComboTierFx(
    type: ComboEffectType.lottie,
    effectUrl: 'x.json',
  ),
);

class _FakeBackend implements SfxBackend {
  _FakeBackend({this.initOk = true, this.playFails = false});
  final bool initOk;
  final bool playFails;
  final List<Object> played = [];

  @override
  Future<bool> init() async => initOk;
  @override
  Future<Object?> load(File file) async => file.path;
  @override
  Future<void> play(Object source) async {
    if (playFails) throw StateError('boom');
    played.add(source);
  }
}

void main() {
  group('ComboTierQueue', () {
    test('descarta itens com mais de 6 s', () {
      var now = DateTime(2026, 1, 1, 12);
      final q = ComboTierQueue(clock: () => now);
      q.add(ev(10));
      now = now.add(const Duration(seconds: 7));
      expect(q.next(), isNull);
      expect(q.isEmpty, isTrue);
    });

    test('espera enquanto há presente em cena', () {
      final q = ComboTierQueue();
      q.add(ev(10));
      expect(q.next(giftPlaying: true), isNull);
      expect(q.length, 1);
      expect(q.next()!.event.at, 10);
    });

    test('degrau maior do mesmo combo substitui o menor', () {
      final q = ComboTierQueue();
      q.add(ev(10));
      q.add(ev(50));
      expect(q.length, 1);
      expect(q.next()!.event.at, 50);
    });

    test('limite de tamanho', () {
      final q = ComboTierQueue(maxLength: 2);
      q.add(ev(10, sender: 'a'));
      q.add(ev(10, sender: 'b'));
      q.add(ev(10, sender: 'c'));
      expect(q.length, 2);
    });
  });

  group('ParticleMath', () {
    test('menos partículas em aparelho fraco', () {
      for (final p in ParticlePreset.values) {
        final full = ParticleMath.countFor(p);
        final low = ParticleMath.countFor(p, lowPerformance: true);
        expect(low, lessThan(full));
        expect(low, greaterThan(0));
      }
    });
    test('paleta com tint mantém o tamanho', () {
      for (final p in ParticlePreset.values) {
        expect(
          ParticleMath.palette(p, tint: Colors.red).length,
          ParticleMath.palette(p).length,
        );
      }
    });
    test('heurística de baixo desempenho', () {
      expect(ParticleMath.isLowPerformance(const Size(320, 640), 3), isTrue);
      expect(ParticleMath.isLowPerformance(const Size(390, 844), 1.5), isTrue);
      expect(ParticleMath.isLowPerformance(const Size(390, 844), 3), isFalse);
    });
  });

  group('ParticleField', () {
    testWidgets('anima e descarta sem erro', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: SizedBox(
          width: 400,
          height: 800,
          child: ParticleField(preset: ParticlePreset.confetti),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('reduzir movimento: só brilho, sem painter animado', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: const ParticleField(preset: ParticlePreset.hearts),
          ),
        ),
      ));
      expect(find.byType(DecoratedBox), findsWidgets);
      expect(
        find.descendant(of: find.byType(ParticleField), matching: find.byType(CustomPaint)),
        findsNothing,
      );
    });
  });

  group('SfxPlayer', () {
    test('usa o principal quando inicia', () async {
      final main = _FakeBackend();
      final fb = _FakeBackend();
      final sfx = SfxPlayer(primary: main, fallback: fb, resolveFile: (u) async => File(u));
      await sfx.play('a.mp3');
      expect(main.played, ['a.mp3']);
      expect(fb.played, isEmpty);
    });

    test('cai no caminho antigo se a inicialização falha', () async {
      final main = _FakeBackend(initOk: false);
      final fb = _FakeBackend();
      final sfx = SfxPlayer(primary: main, fallback: fb, resolveFile: (u) async => File(u));
      await sfx.play('a.mp3');
      expect(main.played, isEmpty);
      expect(fb.played, ['a.mp3']);
      expect(sfx.activeBackend, same(fb));
    });

    test('cai no antigo se tocar falha em execução', () async {
      final main = _FakeBackend(playFails: true);
      final fb = _FakeBackend();
      final sfx = SfxPlayer(primary: main, fallback: fb, resolveFile: (u) async => File(u));
      await sfx.play('a.mp3');
      expect(fb.played, hasLength(1));
    });

    test('arquivo indisponível é silêncio, sem exceção', () async {
      final main = _FakeBackend();
      final sfx = SfxPlayer(primary: main, fallback: _FakeBackend(), resolveFile: (u) async => null);
      await sfx.play('a.mp3');
      await sfx.play(null);
      expect(main.played, isEmpty);
    });
  });
}
