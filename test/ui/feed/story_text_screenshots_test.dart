// PNGs legíveis (fontes reais) do editor de texto do story. Sem asserts de pixel.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:brawe_app/ui/core/themes/app_theme.dart';
import 'package:brawe_app/ui/feed/widgets/story_composer_screen.dart';
import 'package:brawe_app/ui/feed/widgets/story_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _defaultDir =
    '/private/tmp/claude-501/-Volumes-SSD-240GB-EXTERNO-Documentos-Brawe/'
    'ac56cc5f-b3cc-4aea-9f4b-e3fd84662a35/scratchpad/shots-story-text';

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    final bytes = File(p).readAsBytesSync();
    loader.addFont(
      Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)),
    );
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
  });

  const palette = [
    Colors.white,
    Colors.black,
    Color(0xFF2F6BFF),
    Color(0xFF58C4FF),
    Color(0xFFFF4D8D),
    Color(0xFFE5484D),
    Color(0xFFFFB020),
  ];

  Widget stage(GlobalKey key, Widget child, {Gradient? bg}) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    home: Scaffold(
      body: Center(
        child: RepaintBoundary(
          key: key,
          child: Container(
            width: 390,
            height: 560,
            decoration: BoxDecoration(
              gradient: bg,
              color: bg == null ? const Color(0xB8000000) : null,
            ),
            child: child,
          ),
        ),
      ),
    ),
  );

  testWidgets('editor vazio', (tester) async {
    final key = GlobalKey();
    final c = StoryRichTextController(styleFor: (x) => TextStyle(color: x));
    await tester.pumpWidget(
      stage(
        key,
        Column(
          children: [
            const Spacer(),
            debugStoryComposeField(controller: c, color: Colors.white),
            const Spacer(),
            debugStoryColorPalette(
              palette: palette,
              selected: Colors.white,
              onSelect: (_) {},
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    await _shot(tester, key, '01_editor_vazio');
  });

  testWidgets('editor multicolorido', (tester) async {
    final key = GlobalKey();
    final c = StoryRichTextController(
      text: 'Hoje o dia foi incrível demais',
      styleFor: (x) => TextStyle(color: x),
      spans: const [
        StoryColorSpan(8, 11, 0xFFFFB020),
        StoryColorSpan(16, 24, 0xFFFF4D8D),
      ],
    );
    await tester.pumpWidget(
      stage(
        key,
        Column(
          children: [
            const Spacer(),
            debugStoryComposeField(
              controller: c,
              color: Colors.white,
              fontSize: 34,
              maxWidth: 300,
            ),
            const Spacer(),
            debugStoryColorPalette(
              palette: palette,
              selected: Colors.white,
              onSelect: (_) {},
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    await _shot(tester, key, '02_editor_multicolor');
  });

  testWidgets('camada no gradiente', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      stage(
        key,
        Center(
          child: debugStoryTextLayer(
            text: 'Hoje o dia foi incrível demais',
            spans: const [
              StoryColorSpan(8, 11, 0xFFFFB020),
              StoryColorSpan(16, 24, 0xFF000000),
            ],
            color: Colors.white,
            bgIndex: 1,
            canvasWidth: 390,
          ),
        ),
        bg: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2F6BFF), Color(0xFFFF4D8D)],
        ),
      ),
    );
    await _shot(tester, key, '03_camada_gradiente');
  });
}
