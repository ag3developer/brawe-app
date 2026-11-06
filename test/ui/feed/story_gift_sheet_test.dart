import 'package:brawe_app/data/repositories/stories_repository.dart';
import 'package:brawe_app/ui/core/themes/app_colors.dart';
import 'package:brawe_app/ui/core/themes/force_dark_theme.dart';
import 'package:brawe_app/ui/core/ui/verified_badge.dart';
import 'package:brawe_app/ui/feed/widgets/story_gift_sheet.dart';
import 'package:brawe_app/ui/feed/widgets/story_viewer.dart';
import 'package:brawe_app/domain/models/story.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'story_gift_test_support.dart';

Widget _sheet({
  bool verified = false,
  VoidCallback? onRecharge,
  ValueChanged<StoryGiftResult>? onSent,
}) => Align(
  alignment: Alignment.bottomCenter,
  child: StoryGiftSheet(
    storyId: 's1',
    creatorName: 'maria',
    isVerified: verified,
    onRecharge: onRecharge,
    onSent: onSent,
  ),
);

Future<void> _pumpSheet(
  WidgetTester tester, {
  required FakeGiftRepo repo,
  double balance = 100000,
  bool dark = false,
  double scale = 1,
  bool verified = false,
  VoidCallback? onRecharge,
  ValueChanged<StoryGiftResult>? onSent,
}) async {
  await tester.pumpWidget(
    testApp(
      home: Scaffold(
        body: _sheet(verified: verified, onRecharge: onRecharge, onSent: onSent),
      ),
      overrides: giftOverrides(repo: repo, balance: balance),
      dark: dark,
      textScale: scale,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const sizes = [Size(320, 568), Size(390, 844), Size(412, 915)];

  group('sem overflow', () {
    for (final size in sizes) {
      for (final dark in [false, true]) {
        for (final scale in [1.0, 2.0]) {
          testWidgets(
            '${size.width.toInt()}x${size.height.toInt()} '
            '${dark ? 'dark' : 'light'} x$scale',
            (tester) async {
              setScreen(tester, size.width, size.height);
              await _pumpSheet(
                tester,
                repo: FakeGiftRepo(),
                dark: dark,
                scale: scale,
                verified: true,
              );
              expect(tester.takeException(), isNull);
              // estado selecionado (pill "Enviar" no lugar do preço)
              await tester.tap(find.byKey(const Key('gift-tile-gem')));
              await tester.pumpAndSettle();
              expect(find.byKey(const Key('gift-pill-gem')), findsOneWidget);
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  });

  testWidgets('toque seleciona, segundo toque envia uma vez', (tester) async {
    setScreen(tester, 390, 844);
    final repo = FakeGiftRepo();
    final sent = <StoryGiftResult>[];
    await _pumpSheet(tester, repo: repo, onSent: sent.add);
    await tester.tap(find.byKey(const Key('gift-tile-rose')));
    await tester.pumpAndSettle();
    expect(repo.sent, isEmpty);
    expect(find.byKey(const Key('gift-pill-rose')), findsOneWidget);
    await tester.tap(find.byKey(const Key('gift-tile-rose')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(repo.sent, ['rose']);
    expect(sent.single.combo, 1);
    await tester.pump(kStoryGiftComboWindow + const Duration(seconds: 1));
  });

  testWidgets('combo incrementa x2, x3 e zera após a janela', (tester) async {
    setScreen(tester, 390, 844);
    final repo = FakeGiftRepo();
    await _pumpSheet(tester, repo: repo);
    final tile = find.byKey(const Key('gift-tile-rose'));
    await tester.tap(tile);
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await tester.tap(tile);
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(repo.sent.length, 3);
    expect(find.text('x3'), findsOneWidget);
    expect(find.byKey(const Key('gift-combo-rose')), findsOneWidget);
    await tester.pump(kStoryGiftComboWindow + const Duration(milliseconds: 200));
    expect(find.byKey(const Key('gift-combo-rose')), findsNothing);
    // novo toque depois da janela recomeça o combo
    await tester.tap(tile);
    await tester.pump(const Duration(milliseconds: 300));
    expect(repo.sent.length, 4);
    expect(find.byKey(const Key('gift-combo-rose')), findsNothing);
    await tester.pump(kStoryGiftComboWindow + const Duration(seconds: 1));
  });

  testWidgets('presente caro pede confirmação', (tester) async {
    setScreen(tester, 390, 844);
    final repo = FakeGiftRepo();
    await _pumpSheet(tester, repo: repo);
    final tile = find.byKey(const Key('gift-tile-gem'));
    await tester.tap(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(find.textContaining('Enviar Diamante por'), findsOneWidget);
    expect(repo.sent, isEmpty);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(repo.sent, isEmpty);
    await tester.tap(tile);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('story-gift-confirm')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(repo.sent, ['gem']);
    await tester.pump(kStoryGiftComboWindow + const Duration(seconds: 1));
  });

  testWidgets('saldo insuficiente mostra Recarregar e não envia', (tester) async {
    setScreen(tester, 390, 844);
    final repo = FakeGiftRepo();
    var recharged = 0;
    await _pumpSheet(
      tester,
      repo: repo,
      balance: 5,
      onRecharge: () => recharged++,
    );
    final tile = find.byKey(const Key('gift-tile-rose'));
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(find.text('Recarregar'), findsOneWidget);
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(recharged, 1);
    expect(repo.sent, isEmpty);
  });

  testWidgets('selo de verificado no cabeçalho', (tester) async {
    setScreen(tester, 390, 844);
    await _pumpSheet(tester, repo: FakeGiftRepo(), verified: true);
    expect(find.byType(VerifiedBadge), findsOneWidget);
    await _pumpSheet(tester, repo: FakeGiftRepo(), verified: false);
    expect(find.byType(VerifiedBadge), findsNothing);
  });

  testWidgets('sheet de presente segue o tema do app dentro do ForceDarkTheme',
      (tester) async {
    setScreen(tester, 390, 844);
    await tester.pumpWidget(
      testApp(
        overrides: giftOverrides(repo: FakeGiftRepo()),
        home: ForceDarkTheme(
          child: Builder(
            builder: (ctx) => Scaffold(
              body: TextButton(
                onPressed: () => StoryGiftSheet.show(
                  ctx,
                  storyId: 's1',
                  creatorName: 'maria',
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    final theme = Theme.of(tester.element(find.byType(StoryGiftSheet)));
    expect(theme.brightness, Brightness.light);
    final deco = tester
        .widgetList<Container>(find.descendant(
          of: find.byType(StoryGiftSheet),
          matching: find.byType(Container),
        ))
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .map((d) => d.color);
    expect(deco, contains(AppColors.lightSurfaceElevated));
  });

  testWidgets('lista de visualizações usa tokens do tema e mostra selo',
      (tester) async {
    setScreen(tester, 390, 844);
    final repo = FakeStoriesRepo([
      StoryViewerInfo(
        userId: 'u1',
        name: 'Ana Souza',
        username: 'ana',
        isVerified: true,
        viewedAt: DateTime.now(),
      ),
    ]);
    for (final dark in [false, true]) {
      await tester.pumpWidget(
        testApp(
          dark: dark,
          overrides: [storiesRepositoryProvider.overrideWithValue(repo)],
          home: const Scaffold(body: StoryViewersSheet(storyId: 's1')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(VerifiedBadge), findsOneWidget);
      final box = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.color);
      expect(
        box,
        contains(
          dark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        ),
      );
    }
  });
}
