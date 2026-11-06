// Gera PNGs legíveis (fontes reais) das sheets de story, para revisão visual.
// Saída em SHOTS_DIR (ou no scratchpad padrão). Sem asserts de pixel.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:brawe_app/data/repositories/stories_repository.dart';
import 'package:brawe_app/domain/models/story.dart';
import 'package:brawe_app/ui/feed/widgets/story_gift_sheet.dart';
import 'package:brawe_app/ui/feed/widgets/story_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'story_gift_test_support.dart';

const _defaultDir =
    '/private/tmp/claude-501/-Volumes-SSD-240GB-EXTERNO-Documentos-Brawe/'
    'ac56cc5f-b3cc-4aea-9f4b-e3fd84662a35/scratchpad/shots-story-gifts';

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    final bytes = File(p).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)));
  }
  await loader.load();
}

Future<void> _shot(WidgetTester tester, GlobalKey key, String name) async {
  final dir = Directory(Platform.environment['SHOTS_DIR'] ?? _defaultDir)
    ..createSync(recursive: true);
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File('${dir.path}/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(() async {
    final root = Platform.environment['FLUTTER_ROOT']!;
    final fonts = '$root/bin/cache/artifacts/material_fonts';
    await _loadFont('Roboto', [
      '$fonts/Roboto-Regular.ttf',
      '$fonts/Roboto-Medium.ttf',
      '$fonts/Roboto-Bold.ttf',
      '$fonts/Roboto-Black.ttf',
    ]);
    await _loadFont('MaterialIcons', ['$fonts/MaterialIcons-Regular.otf']);
  });

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';

    testWidgets('gift sheet $mode', (tester) async {
      setScreen(tester, 390, 844);
      final key = GlobalKey();
      final repo = FakeGiftRepo();
      await tester.pumpWidget(
        testApp(
          boundaryKey: key,
          dark: dark,
          overrides: giftOverrides(repo: repo, balance: 2450),
          home: Scaffold(
            backgroundColor: Colors.black87,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: StoryGiftSheet(
                storyId: 's1',
                creatorName: 'maria.silva',
                isVerified: true,
                onRecharge: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _shot(tester, key, 'gift-sheet-$mode');

      // selecionado + combo x3
      final tile = find.byKey(const Key('gift-tile-cafe'));
      await tester.tap(tile);
      await tester.pumpAndSettle();
      await _shot(tester, key, 'gift-sheet-$mode-selected');
      for (var i = 0; i < 3; i++) {
        await tester.tap(tile);
        await tester.pump(const Duration(milliseconds: 300));
      }
      await tester.pump(const Duration(milliseconds: 400));
      await _shot(tester, key, 'gift-sheet-$mode-combo');
      await tester.pump(kStoryGiftComboWindow + const Duration(seconds: 1));
    });

    testWidgets('viewers sheet $mode', (tester) async {
      setScreen(tester, 390, 844);
      final key = GlobalKey();
      final repo = FakeStoriesRepo([
        StoryViewerInfo(
          userId: 'u1',
          name: 'Ana Souza',
          username: 'ana',
          isVerified: true,
          viewedAt: DateTime.now().subtract(const Duration(minutes: 12)),
          reaction: '🔥',
        ),
        StoryViewerInfo(
          userId: 'u2',
          name: 'Bruno Lima',
          username: 'brunol',
          viewedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        StoryViewerInfo(
          userId: 'u3',
          name: 'Carla Dias',
          username: 'carla',
          isVerified: true,
          viewedAt: DateTime.now().subtract(const Duration(hours: 5)),
          reaction: '❤️',
        ),
      ]);
      await tester.pumpWidget(
        testApp(
          boundaryKey: key,
          dark: dark,
          overrides: [storiesRepositoryProvider.overrideWithValue(repo)],
          home: const Scaffold(
            backgroundColor: Colors.black87,
            body: StoryViewersSheet(storyId: 's1'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _shot(tester, key, 'viewers-sheet-$mode');
    });
  }
}
