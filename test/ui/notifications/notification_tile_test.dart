import 'package:brawe_app/domain/models/app_notification.dart';
import 'package:brawe_app/gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/core/themes/app_theme.dart';
import 'package:brawe_app/ui/notifications/notification_presentation.dart';
import 'package:brawe_app/ui/notifications/widgets/notification_sections.dart';
import 'package:brawe_app/ui/notifications/widgets/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {bool dark = false, double scale = 1}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  locale: const Locale('pt'),
  theme: dark ? AppTheme.dark() : AppTheme.light(),
  builder: (context, c) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: c!,
  ),
  home: Scaffold(body: child),
);

AppNotification _n(
  int count, {
  String id = 'n',
  bool read = false,
  String type = 'post_liked',
  String key = 'like:p1',
  DateTime? at,
  String? thumb,
  int value = 0,
}) {
  const names = ['Ana Beatriz Fernanda de Albuquerque', 'Bruno', 'Carla'];
  final shown = count.clamp(1, 3);
  return AppNotification(
    id: id,
    type: type,
    title: 'servidor',
    message: '',
    isRead: read,
    groupKey: key,
    actorsCount: count,
    groupValue: value,
    thumbnailUrl: thumb,
    createdAt: at ?? DateTime.now(),
    actors: [for (var i = 0; i < shown; i++) NotifActor(id: 'u$i', name: names[i])],
  );
}

void main() {
  for (final dark in [false, true]) {
    for (final w in [320.0, 390.0]) {
      for (final scale in [1.0, 2.0]) {
        for (final count in [1, 2, 3, 14]) {
          testWidgets('${dark ? "escuro" : "claro"} $w x$scale atores=$count', (tester) async {
            tester.view.physicalSize = Size(w * 2, 900 * 2);
            tester.view.devicePixelRatio = 2;
            addTearDown(tester.view.reset);
            await tester.pumpWidget(
              _app(
                NotificationTile(notification: _n(count, thumb: null), onTap: () {}),
                dark: dark,
                scale: scale,
              ),
            );
            await tester.pump();
            expect(tester.takeException(), isNull);
            expect(find.textContaining('Bruno').evaluate().isNotEmpty || count == 1, isTrue);
            expect(find.byKey(const ValueKey('notif-unread-dot')), findsOneWidget);
          });
        }
      }
    }
  }

  testWidgets('texto resumido por quantidade de atores', (tester) async {
    for (final (count, text) in [
      (1, 'Ana Beatriz Fernanda de Albuquerque curtiu seu post'),
      (2, 'Ana Beatriz Fernanda de Albuquerque e Bruno curtiram seu post'),
      (14, 'Ana Beatriz Fernanda de Albuquerque, Bruno e mais 12 curtiram seu post'),
    ]) {
      await tester.pumpWidget(_app(NotificationTile(notification: _n(count), onTap: () {})));
      await tester.pump();
      expect(find.textContaining(text, findRichText: true), findsOneWidget, reason: '$count');
    }
  });

  testWidgets('lida: sem bolinha; toque chama onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_app(NotificationTile(notification: _n(2, read: true), onTap: () => taps++)));
    expect(find.byKey(const ValueKey('notif-unread-dot')), findsNothing);
    await tester.tap(find.byType(NotificationTile));
    expect(taps, 1);
  });

  testWidgets('miniatura do post aparece quando há thumbnail_url', (tester) async {
    await tester.pumpWidget(_app(NotificationTile(notification: _n(2, thumb: 'http://localhost/t.jpg'), onTap: () {})));
    await tester.pump();
    expect(find.byKey(const ValueKey('notif-thumb')), findsOneWidget);
  });

  testWidgets('seções Hoje / Esta semana / Anteriores na ordem', (tester) async {
    final now = DateTime(2026, 11, 6, 12);
    await tester.pumpWidget(
      _app(
        NotificationSectionsList(
          now: now,
          onOpen: (_) {},
          onRemove: (_) {},
          items: [
            _n(1, id: 'a', at: DateTime(2026, 11, 6, 10)),
            _n(2, id: 'b', at: DateTime(2026, 11, 3)),
            _n(3, id: 'c', at: DateTime(2026, 9, 1)),
          ],
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Hoje'), findsOneWidget);
    expect(find.text('Esta semana'), findsOneWidget);
    expect(find.text('Anteriores'), findsOneWidget);
    double y(String t) => tester.getTopLeft(find.text(t)).dy;
    expect(y('Hoje') < y('Esta semana'), isTrue);
    expect(y('Esta semana') < y('Anteriores'), isTrue);
  });

  for (final dark in [false, true]) {
    for (final w in [320.0, 390.0]) {
      testWidgets('chips de filtro ${dark ? "escuro" : "claro"} $w x2', (tester) async {
        tester.view.physicalSize = Size(w * 2, 900 * 2);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.reset);
        NotifFilter? picked;
        await tester.pumpWidget(
          _app(
            NotificationFilterBar(
              selected: NotifFilter.all,
              unreadBy: const {NotifFilter.likes: 3, NotifFilter.followers: 120},
              totalUnread: 123,
              onSelect: (f) => picked = f,
            ),
            dark: dark,
            scale: 2,
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('Tudo'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('notif-chip-all')));
        expect(picked, NotifFilter.all);
        await tester.drag(find.byType(Scrollable).first, const Offset(-3000, 0));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('notif-chip-brawe')));
        expect(picked, NotifFilter.brawe);
      });
    }
  }

  testWidgets('filtro mostra os 7 chips', (tester) async {
    await tester.pumpWidget(
      _app(
        NotificationFilterBar(
          selected: NotifFilter.likes,
          unreadBy: const {},
          totalUnread: 0,
          onSelect: (_) {},
        ),
      ),
    );
    for (final f in NotifFilter.values) {
      expect(find.byKey(ValueKey('notif-chip-${f.name}'), skipOffstage: false), findsOneWidget);
    }
    expect(NotifFilter.values.length, 7);
  });
}
