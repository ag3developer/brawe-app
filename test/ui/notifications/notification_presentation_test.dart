import 'package:brawe_app/data/services/push_grouping.dart';
import 'package:brawe_app/domain/models/app_notification.dart';
import 'package:brawe_app/gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/notifications/notification_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AppNotification _n({
  String type = 'post_liked',
  String? key = 'like:p1',
  int count = 1,
  List<String> names = const ['Ana'],
  int value = 0,
  String title = 'Ana curtiu sua foto',
  Map<String, dynamic>? data,
}) => AppNotification(
  id: 'n',
  type: type,
  title: title,
  message: '',
  isRead: false,
  groupKey: key,
  actorsCount: count,
  groupValue: value,
  data: data,
  actors: [
    for (var i = 0; i < names.length; i++)
      NotifActor(id: 'u$i', name: names[i]),
  ],
);

Future<S> _s(String lang) => S.delegate.load(Locale(lang));

void main() {
  group('texto agrupado', () {
    test('pt: 1, 2, 3 e muitos', () async {
      final s = await _s('pt');
      expect(NotifPresentation.title(s, _n()), 'Ana curtiu seu post');
      expect(
        NotifPresentation.title(s, _n(count: 2, names: ['Ana', 'Bruno'])),
        'Ana e Bruno curtiram seu post',
      );
      expect(
        NotifPresentation.title(s, _n(count: 3, names: ['Ana', 'Bruno', 'Carla'])),
        'Ana, Bruno e Carla curtiram seu post',
      );
      expect(
        NotifPresentation.title(s, _n(count: 14, names: ['Ana', 'Bruno', 'Carla'])),
        'Ana, Bruno e mais 12 curtiram seu post',
      );
    });

    test('en e es', () async {
      final en = await _s('en');
      final es = await _s('es');
      final three = ['Ana', 'Bruno', 'Carla'];
      expect(NotifPresentation.title(en, _n(names: ['Ana'])), 'Ana liked your post');
      expect(
        NotifPresentation.title(en, _n(count: 14, names: three)),
        'Ana, Bruno and 12 others liked your post',
      );
      expect(
        NotifPresentation.title(en, _n(count: 4, names: three)),
        'Ana, Bruno and 2 others liked your post',
      );
      expect(
        NotifPresentation.title(es, _n(count: 14, names: three)),
        'Ana, Bruno y 12 más les gustó tu publicación',
      );
      expect(NotifPresentation.title(es, _n(names: ['Ana'])), 'Ana le gustó tu publicación');
    });

    test('presentes com diamantes formatados', () async {
      final pt = await _s('pt');
      final en = await _s('en');
      final n = _n(
        type: 'gift_received',
        key: 'gift:r1',
        count: 6,
        names: ['Ana', 'Bia', 'Caio'],
        value: 1240,
      );
      expect(
        NotifPresentation.title(pt, n),
        'Ana, Bia e mais 4 enviaram presentes na sua live (1.240 diamantes)',
      );
      expect(
        NotifPresentation.title(en, n),
        'Ana, Bia and 4 others sent gifts in your live (1,240 diamonds)',
      );
    });

    test('sem agrupamento usa o título do servidor', () async {
      final pt = await _s('pt');
      final old = _n(key: null, title: 'Ana curtiu sua foto');
      expect(NotifPresentation.title(pt, old), 'Ana curtiu sua foto');
      final sys = _n(type: 'system', key: null, title: 'Aviso');
      expect(NotifPresentation.title(pt, sys), 'Aviso');
    });
  });

  group('filtros e seções', () {
    test('categorias', () {
      expect(NotifPresentation.filterOf(_n()), NotifFilter.likes);
      expect(NotifPresentation.filterOf(_n(type: 'post_commented')), NotifFilter.comments);
      expect(NotifPresentation.filterOf(_n(type: 'follow')), NotifFilter.followers);
      expect(NotifPresentation.filterOf(_n(type: 'gift_received')), NotifFilter.gifts);
      expect(NotifPresentation.filterOf(_n(type: 'comment_mention')), NotifFilter.mentions);
      expect(NotifPresentation.filterOf(_n(type: 'system')), NotifFilter.brawe);
      expect(NotifPresentation.filterOf(_n(type: 'live_started')), isNull);
      expect(NotifPresentation.matches(NotifFilter.all, _n(type: 'live_started')), isTrue);
      expect(NotifPresentation.matches(NotifFilter.likes, _n(type: 'follow')), isFalse);
    });

    test('seções hoje / esta semana / anteriores', () {
      final now = DateTime(2026, 11, 6, 12);
      expect(NotifPresentation.bucketOf(DateTime(2026, 11, 6, 1), now), NotifBucket.today);
      expect(NotifPresentation.bucketOf(DateTime(2026, 11, 5, 23), now), NotifBucket.week);
      expect(NotifPresentation.bucketOf(DateTime(2026, 10, 29), now), NotifBucket.older);
      expect(NotifPresentation.bucketOf(null, now), NotifBucket.older);
    });

    test('grupo de seguidores abre a lista', () {
      final multi = _n(type: 'follow', key: 'follow:u:2026-11-06', count: 5, names: ['A', 'B', 'C']);
      final single = _n(type: 'follow', key: 'follow:u:2026-11-06', count: 1);
      expect(NotifPresentation.isFollowGroup(multi), isTrue);
      expect(NotifPresentation.isFollowGroup(single), isFalse);
    });
  });

  group('modelo (compat com backend antigo)', () {
    test('sem campos novos: 1 ator derivado de actor_*', () {
      final n = AppNotification.fromJson({
        'id': '1',
        'type': 'post_liked',
        'title': 'Ana curtiu sua foto',
        'message': 'Toque para ver',
        'is_read': false,
        'actor_id': 'a1',
        'actor_name': 'Ana',
        'actor_avatar': 'http://x/a.jpg',
      });
      expect(n.groupKey, isNull);
      expect(n.isGrouped, isFalse);
      expect(n.actors.single.name, 'Ana');
      expect(n.actorsCount, 1);
    });

    test('com campos novos', () {
      final n = AppNotification.fromJson({
        'id': '1',
        'type': 'post_liked',
        'title': 't',
        'is_read': false,
        'group_key': 'like:p1',
        'actors': [
          {'id': 'a', 'name': 'Ana', 'avatar': null},
          {'id': 'b', 'name': 'Bruno'},
        ],
        'actors_count': 9,
        'group_value': 0,
        'thumbnail_url': 'http://x/t.jpg',
      });
      expect(n.isGrouped, isTrue);
      expect(n.actorsCount, 9);
      expect(n.actors.length, 2);
      expect(n.thumbnailUrl, 'http://x/t.jpg');
      expect(n.copyWith(isRead: true).groupKey, 'like:p1');
    });
  });

  test('push em foreground usa a chave de agregação como tag', () {
    final data = {'groupKey': 'like:p1', 'type': 'post_liked'};
    expect(PushGrouping.groupKey(data), 'like:p1');
    expect(PushGrouping.notificationId('like:p1'), PushGrouping.notificationId('like:p1'));
    expect(PushGrouping.groupKey({'type': 'new_message', 'conversation_id': 'c1', 'groupKey': 'x'}), 'c1');
    expect(PushGrouping.groupKey({'type': 'system'}), isNull);
  });
}
