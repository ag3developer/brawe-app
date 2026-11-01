import 'package:brawe_app/domain/models/profile.dart';
import 'package:brawe_app/domain/models/user_award.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _a(String kind, String label, {String? exp, String? frame}) => {
  'id': label,
  'source_kind': kind,
  'label': {'pt': label, 'en': '$label EN'},
  'badge_color': '#112233',
  'frame_url': ?frame,
  'expires_at': ?exp,
};

void main() {
  final now = DateTime.utc(2026, 11, 1);

  test('tryParse completo e localizado', () {
    final a = UserAward.tryParse({
      'label': {'pt': 'Rei', 'en': 'King', 'es': 'Rey'},
      'badge_image_url': 'https://x/b.png',
      'badge_color': '#FFD700',
      'frame_url': 'https://x/f.png',
    })!;
    expect(a.localizedLabel('es'), 'Rey');
    expect(a.localizedLabel('fr'), 'Rei');
    expect(a.badgeImageUrl, 'https://x/b.png');
    expect(a.frameUrl, 'https://x/f.png');
    expect(a.expiresAt, isNull);
  });

  test('tryParse tolera lixo / ausência', () {
    expect(UserAward.tryParse(null), isNull);
    expect(UserAward.tryParse({'badge_color': '#fff'}), isNull); // sem label
    expect(UserAward.tryParse({'label': ''}), isNull);
    expect(UserAward.listFrom('x'), isEmpty);
    final a = UserAward.tryParse({'label': 'Só texto', 'badge_image_url': ''})!;
    expect(a.badgeImageUrl, isNull);
    expect(a.localizedLabel('en'), 'Só texto');
  });

  test('prioridade: evento > semana > live > batalha', () {
    final list = UserAward.listFrom([
      _a('battle', 'b'),
      _a('live', 'l'),
      _a('creator_week', 'w'),
      _a('event', 'e'),
    ]);
    expect(UserAward.mostPrestigious(list, now: now)!.id, 'e');
    expect(UserAward.mostPrestigious(list.sublist(0, 3), now: now)!.id, 'w');
    expect(UserAward.mostPrestigious(list.sublist(0, 2), now: now)!.id, 'l');
  });

  test('empate de prioridade fica com o de validade mais distante', () {
    final list = UserAward.listFrom([
      _a('live', 'velho', exp: '2026-11-10T00:00:00Z'),
      _a('live', 'novo', exp: '2026-12-10T00:00:00Z'),
    ]);
    expect(UserAward.mostPrestigious(list, now: now)!.id, 'novo');
  });

  test('ignora expirados e lista vazia', () {
    final list = UserAward.listFrom([
      _a('event', 'expirado', exp: '2026-10-01T00:00:00Z'),
      _a('battle', 'valido', exp: '2026-12-01T00:00:00Z'),
    ]);
    expect(UserAward.mostPrestigious(list, now: now)!.id, 'valido');
    expect(UserAward.mostPrestigious(const [], now: now), isNull);
    expect(UserAward.mostPrestigious(list.sublist(0, 1), now: now), isNull);
  });

  test('Profile.active_awards: presente e ausente', () {
    final p = Profile.fromJson({
      'id': 'u1',
      'active_awards': [_a('event', 'Halloween', frame: 'https://x/f.png'), 'lixo'],
    });
    expect(p.activeAwards.length, 1);
    expect(p.activeAwards.first.frameUrl, 'https://x/f.png');
    expect(Profile.fromJson({'id': 'u1'}).activeAwards, isEmpty);
  });
}
