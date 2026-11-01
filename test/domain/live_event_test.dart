import 'package:brawe_app/domain/models/live_event.dart';
import 'package:brawe_app/domain/models/live_viewer_event.dart';
import 'package:brawe_app/ui/live_feed/view_models/live_room_comments_view_model.dart'
    show GifterEntry;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ends = DateTime.utc(2026, 11, 1, 12);

  group('LiveEvent.tryParse', () {
    test('parseia evento completo', () {
      final e = LiveEvent.tryParse({
        'id': 'ev1',
        'slug': 'halloween',
        'name': {'pt': 'Halloween', 'en': 'Halloween EN', 'es': 'Noche'},
        'multiplier': 2.0,
        'ends_at': ends.toIso8601String(),
        'banner_image_url': 'https://x/b.png',
      })!;
      expect(e.id, 'ev1');
      expect(e.multiplier, 2.0);
      expect(e.multiplierLabel, '2×');
      expect(e.localizedName('en'), 'Halloween EN');
      expect(e.localizedName('fr'), 'Halloween'); // cai para pt
      expect(e.bannerImageUrl, 'https://x/b.png');
      expect(e.endsAt.toUtc(), ends);
    });

    test('tolera campos ausentes e servidor antigo', () {
      expect(LiveEvent.tryParse(null), isNull);
      expect(LiveEvent.tryParse('x'), isNull);
      expect(LiveEvent.tryParse({'id': 'a'}), isNull); // sem ends_at
      expect(LiveEvent.tryParse({'ends_at': ends.toIso8601String()}), isNull);
      final e = LiveEvent.tryParse({
        'id': 'a',
        'slug': 's',
        'ends_at': ends.toIso8601String(),
        'multiplier': '1.5',
        'banner_image_url': '',
      })!;
      expect(e.localizedName('pt'), 's'); // nome vazio -> slug
      expect(e.multiplierLabel, '1.5×');
      expect(e.bannerImageUrl, isNull);
    });

    test('multiplicador inválido vira 1x', () {
      final e = LiveEvent.tryParse({
        'id': 'a',
        'ends_at': ends.toIso8601String(),
        'multiplier': 'abc',
      })!;
      expect(e.multiplier, 1.0);
    });

    test('remaining e isEnded', () {
      final e = LiveEvent.tryParse({'id': 'a', 'ends_at': ends.toIso8601String()})!;
      expect(e.remaining(ends.subtract(const Duration(minutes: 5))),
          const Duration(minutes: 5));
      expect(e.remaining(ends.add(const Duration(hours: 1))), Duration.zero);
      expect(e.isEnded(ends), isTrue);
      expect(e.isEnded(ends.subtract(const Duration(seconds: 1))), isFalse);
    });
  });

  group('formatEventCountdown', () {
    test('hh:mm:ss', () {
      expect(formatEventCountdown(const Duration(hours: 5, minutes: 12, seconds: 30)),
          '05:12:30');
      expect(formatEventCountdown(const Duration(seconds: 9)), '00:00:09');
      expect(formatEventCountdown(Duration.zero), '00:00:00');
    });
    test('negativo vira zero; >= 1 dia usa dias', () {
      expect(formatEventCountdown(const Duration(seconds: -4)), '00:00:00');
      expect(formatEventCountdown(const Duration(days: 2, hours: 5, minutes: 3)),
          '2d 05h');
      expect(formatEventCountdown(const Duration(hours: 23, minutes: 59, seconds: 59)),
          '23:59:59');
    });
  });

  group('multiplicador', () {
    test('formatMultiplier', () {
      expect(formatMultiplier(2), '2×');
      expect(formatMultiplier(1.5), '1.5×');
    });
    test('activeMultiplier só acima de 1', () {
      expect(activeMultiplier(2.0), 2.0);
      expect(activeMultiplier('3'), 3.0);
      expect(activeMultiplier(1.0), isNull);
      expect(activeMultiplier(null), isNull);
      expect(activeMultiplier('x'), isNull);
    });
  });

  group('PrizeRule', () {
    test('parseia label string ou localizado', () {
      final list = PrizeRule.listFrom([
        {'rank_from': 1, 'rank_to': 1, 'label': 'Emblema'},
        {
          'rank_from': 2,
          'rank_to': 3,
          'label': {'pt': 'Moldura', 'en': 'Frame'},
        },
        {'rank_from': 0, 'rank_to': 1, 'label': 'x'}, // inválido
        {'rank_from': 1, 'rank_to': 1}, // sem label
        'lixo',
      ]);
      expect(list.length, 2);
      expect(list[0].label.resolve('pt'), 'Emblema');
      expect(list[1].label.resolve('en'), 'Frame');
      expect(list[1].covers(3), isTrue);
      expect(list[1].covers(1), isFalse);
    });

    test('firstPlace', () {
      final list = PrizeRule.listFrom([
        {'rank_from': 2, 'rank_to': 3, 'label': 'B'},
        {'rank_from': 1, 'rank_to': 3, 'label': 'A'},
      ]);
      expect(PrizeRule.firstPlace(list)!.label.resolve('pt'), 'A');
      expect(PrizeRule.firstPlace(const []), isNull);
      expect(PrizeRule.listFrom(null), isEmpty);
    });
  });

  group('award em payloads', () {
    test('GifterEntry e LiveViewerEvent leem award; sem award = null', () {
      final award = {
        'label': {'pt': 'Campeão'},
        'badge_image_url': 'https://x/b.png',
        'badge_color': '#FFAA00',
        'frame_url': 'https://x/f.png',
      };
      final g = GifterEntry.fromMap({'user_id': 'u', 'points': 10, 'award': award})!;
      expect(g.award!.frameUrl, 'https://x/f.png');
      expect(GifterEntry.fromMap({'user_id': 'u'})!.award, isNull);

      final v = LiveViewerEvent.fromSocket({'user_id': 'u', 'award': award}, joined: true);
      expect(v.award!.localizedLabel('pt'), 'Campeão');
      expect(LiveViewerEvent.fromSocket({'user_id': 'u'}, joined: true).award, isNull);
    });
  });
}
