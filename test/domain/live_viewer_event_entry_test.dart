import 'package:brawe_app/domain/models/gift_presentation.dart';
import 'package:brawe_app/domain/models/live_viewer_event.dart';
import 'package:brawe_app/ui/live/shared/widgets/overlays/entrance_effect_queue.dart';
import 'package:flutter_test/flutter_test.dart';

LiveViewerEvent ev(String id, {Map<String, dynamic>? extra, int? rank}) =>
    LiveViewerEvent.fromSocket({
      'user_id': id,
      'viewer_name': id,
      'level': 12,
      if (rank != null) 'ranking_position': rank,
      ...?extra,
    }, joined: true);

const vap = {'type': 'vap', 'url': 'https://cdn/x.mp4', 'sound_enabled': true};

void main() {
  group('parser', () {
    test('servidor antigo: sem entry', () {
      final e = ev('a');
      expect(e.entry, isNull);
      expect(e.tierName, isNull);
      expect(e.localizedTierName('en'), isNull);
    });

    test('entry vap com presentation e som', () {
      final e = ev('a', extra: {
        'entry': {
          'type': 'vap',
          'url': 'https://cdn/x.mp4',
          'presentation': {'scale': 0.9},
          'sound_enabled': false,
        },
        'badge': {'badge': '👑', 'name': {'pt': 'Rei', 'en': 'King', 'es': ''}},
      });
      expect(e.entry!.isVap, isTrue);
      expect(e.entry!.soundEnabled, isFalse);
      expect(e.entry!.presentation!['scale'], 0.9);
      expect(e.localizedTierName('en'), 'King');
      expect(e.localizedTierName('es'), 'Rei'); // vazio cai no pt
      expect(e.localizedTierName('fr'), 'Rei');
    });

    test('tipos inválidos ou url vazia viram null', () {
      expect(ev('a', extra: {'entry': {'type': 'none', 'url': 'u'}}).entry, isNull);
      expect(ev('a', extra: {'entry': {'type': 'lottie', 'url': ''}}).entry, isNull);
      expect(ev('a', extra: {'entry': 'x'}).entry, isNull);
      expect(ev('a', extra: {'entry': null}).entry, isNull);
    });

    test('lottie e presentation nula usa o padrão de entrada', () {
      final e = ev('a', extra: {'entry': {'type': 'lottie', 'url': 'https://c/a.json'}});
      expect(e.entry!.isVap, isFalse);
      final pr = GiftPresentation.parse(e.entry!.presentation,
          fallback: GiftPresentation.entranceDefault);
      expect(pr.enter.type, GiftTransition.slideLeft);
      expect(pr.enter.ms, 400);
      expect(pr.layer, GiftLayer.underChat);
      expect(pr.scale, 0.6);
      expect(pr.haptic, GiftHaptic.light);
    });

    test('entry torna a entrada especial mesmo com nível baixo', () {
      final e = LiveViewerEvent.fromSocket(
          {'user_id': 'a', 'level': 2, 'entry': vap}, joined: true);
      expect(e.isSpecialEntry, isTrue);
    });
  });

  group('fila', () {
    late DateTime now;
    late EntranceEffectQueue q;
    setUp(() {
      now = DateTime(2026);
      q = EntranceEffectQueue(clock: () => now);
    });

    test('ignora sem entry, eu mesmo e duplicados', () {
      expect(q.add(ev('a')), isFalse);
      expect(q.add(ev('me', extra: {'entry': vap}), ignoreUserIds: {'me'}), isFalse);
      expect(q.add(ev('b', extra: {'entry': vap})), isTrue);
      expect(q.add(ev('b', extra: {'entry': vap})), isFalse);
      expect(q.length, 1);
    });

    test('não entrega com presente em cena e mantém o item', () {
      q.add(ev('b', extra: {'entry': vap}));
      expect(q.next(giftPlaying: true), isNull);
      expect(q.next()!.event.userId, 'b');
    });

    test('descarta entradas com mais de 8s', () {
      q.add(ev('b', extra: {'entry': vap}));
      now = now.add(const Duration(seconds: 9));
      q.add(ev('c', extra: {'entry': vap}));
      expect(q.next()!.event.userId, 'c');
      expect(q.next(), isNull);
    });

    test('top 1 passa na frente e limite da fila', () {
      for (final id in ['a', 'b', 'c', 'd']) {
        q.add(ev(id, extra: {'entry': vap}));
      }
      q.add(ev('top', extra: {'entry': vap}, rank: 1));
      expect(q.length, 4);
      expect(q.next()!.event.userId, 'top');
    });
  });
}
