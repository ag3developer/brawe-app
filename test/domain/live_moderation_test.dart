import 'package:brawe_app/domain/models/battle_config.dart';
import 'package:brawe_app/domain/models/live_moderation.dart';
import 'package:brawe_app/domain/models/live_viewer_event.dart';
import 'package:brawe_app/domain/models/quest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatPin', () {
    test('parses the full payload', () {
      final p = ChatPin.tryParse({
        'text': 'Regras da live',
        'author_name': 'Ana',
        'author_id': 'u1',
        'pinned_by': 'u9',
        'pinned_by_name': 'Criador',
        'message_id': 'm1',
        'at': '2026-11-01T20:00:00Z',
      })!;
      expect(p.text, 'Regras da live');
      expect(p.authorName, 'Ana');
      expect(p.authorId, 'u1');
      expect(p.pinnedBy, 'u9');
      expect(p.messageId, 'm1');
      expect(p.at!.toUtc(), DateTime.utc(2026, 11, 1, 20));
    });

    test('null / empty / non-map means no pin', () {
      expect(ChatPin.tryParse(null), isNull);
      expect(ChatPin.tryParse('x'), isNull);
      expect(ChatPin.tryParse({'text': '  '}), isNull);
    });

    test('author falls back to the pinner name', () {
      final p = ChatPin.tryParse({'text': 'oi', 'pinned_by_name': 'Mod'})!;
      expect(p.authorName, 'Mod');
    });
  });

  group('ChatError', () {
    test('maps every server code', () {
      expect(ChatError.kindFromCode('blocked_word'), ChatErrorKind.blockedWord);
      expect(ChatError.kindFromCode('link'), ChatErrorKind.link);
      expect(ChatError.kindFromCode('phone'), ChatErrorKind.phone);
      expect(ChatError.kindFromCode('muted'), ChatErrorKind.muted);
      expect(ChatError.kindFromCode('slow_mode'), ChatErrorKind.slowMode);
      expect(ChatError.kindFromCode('???'), ChatErrorKind.unknown);
      expect(ChatError.kindFromCode(null), ChatErrorKind.unknown);
    });

    test('parses until as local time', () {
      final e = ChatError.tryParse({
        'room_id': 'r',
        'code': 'muted',
        'message': 'Você está silenciado',
        'until': '2026-11-01T21:30:00Z',
      })!;
      expect(e.kind, ChatErrorKind.muted);
      expect(e.until!.toUtc(), DateTime.utc(2026, 11, 1, 21, 30));
    });

    test('muted without until stays null (rest of the live)', () {
      final e = ChatError.tryParse({'code': 'muted'})!;
      expect(e.until, isNull);
    });
  });

  test('slow_mode interval: 0 = off, junk ignored', () {
    expect(parseSlowModeInterval({'interval_s': 3}), 3);
    expect(parseSlowModeInterval({'interval_s': 0}), 0);
    expect(parseSlowModeInterval({'interval_s': '5'}), 5);
    expect(parseSlowModeInterval({'interval_s': -2}), 0);
    expect(parseSlowModeInterval({'slow_mode_s': 4}), 4);
    expect(parseSlowModeInterval({'x': 1}), isNull);
    expect(parseSlowModeInterval(null), isNull);
  });

  test('chat_muted notice', () {
    final on = ChatMuteNotice.tryParse({'until': '2026-11-01T21:30:00Z'})!;
    expect(on.muted, isTrue);
    expect(on.until, isNotNull);
    final forever = ChatMuteNotice.tryParse({'until': null})!;
    expect(forever.muted, isTrue);
    expect(forever.until, isNull);
    final off = ChatMuteNotice.tryParse({'until': null, 'muted': false})!;
    expect(off.muted, isFalse);
  });

  test('moderators list', () {
    final list = LiveModerator.parseList({
      'success': true,
      'data': [
        {'user_id': 'a', 'name': 'Ana', 'username': 'ana', 'avatar_url': 'u'},
        {'name': 'sem id'},
        {'user_id': 'b', 'name': null, 'username': 'bob'},
      ],
    });
    expect(list.map((m) => m.userId), ['a', 'b']);
    expect(list[1].name, 'bob');
    expect(LiveModerator.parseList(null), isEmpty);
  });

  test('viewer_joined carries is_moderator', () {
    final e = LiveViewerEvent.fromSocket({
      'user_id': 'u',
      'viewer_name': 'X',
      'is_moderator': true,
    }, joined: true);
    expect(e.isModerator, isTrue);
    expect(
      LiveViewerEvent.fromSocket({'user_id': 'u'}, joined: true).isModerator,
      isFalse,
    );
  });

  group('BattleConfig', () {
    test('parses data envelope', () {
      final c = BattleConfig.tryParse({
        'success': true,
        'data': {'durations_s': [600, 180, 300], 'default_duration_s': 300},
      })!;
      expect(c.durationsS, [180, 300, 600]);
      expect(c.defaultDurationS, 300);
    });

    test('top-level keys also work; default outside list falls to first', () {
      final c = BattleConfig.tryParse({
        'durations_s': [120, 240],
        'default_duration_s': 999,
      })!;
      expect(c.durationsS, [120, 240]);
      expect(c.defaultDurationS, 120);
    });

    test('invalid payloads return null (caller keeps fallback)', () {
      expect(BattleConfig.tryParse(null), isNull);
      expect(BattleConfig.tryParse({'data': {'durations_s': []}}), isNull);
      expect(BattleConfig.tryParse({'durations_s': [0, -1]}), isNull);
      expect(BattleConfig.fallback.durationsS, [180, 300, 600]);
      expect(BattleConfig.fallback.defaultDurationS, 300);
    });
  });

  group('DailyQuest', () {
    Map<String, dynamic> base() => {
      'id': '1',
      'quest_key': 'k',
      'title': 'Assistir',
      'description': 'd',
    };

    test('new fields', () {
      final q = DailyQuest.fromJson({
        ...base(),
        'frequency': 'weekly',
        'event_id': 'e1',
        'resets_in_seconds': 3600,
      });
      expect(q.isWeekly, isTrue);
      expect(q.isEvent, isFalse);
      expect(q.eventId, 'e1');
      expect(q.resetsInSeconds, 3600);
      expect(q.copyWith(isClaimed: true).frequency, 'weekly');
    });

    test('old server and junk frequency default to daily', () {
      expect(DailyQuest.fromJson(base()).frequency, 'daily');
      expect(
        DailyQuest.fromJson({...base(), 'frequency': 'monthly'}).frequency,
        'daily',
      );
      expect(DailyQuest.fromJson({...base(), 'frequency': 'event'}).isEvent, isTrue);
    });
  });
}
