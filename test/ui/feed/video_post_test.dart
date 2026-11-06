import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:brawe_app/gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/core/themes/app_theme.dart';
import 'package:brawe_app/ui/core/themes/brawe_colors.dart';
import 'package:brawe_app/ui/feed/view_models/video_upload_manager.dart';
import 'package:brawe_app/ui/feed/widgets/video_composer_view.dart';
import 'package:brawe_app/ui/feed/widgets/video_upload_pill.dart';
import 'package:brawe_app/ui/feed/widgets/video_cover_picker_sheet.dart';
import 'package:brawe_app/ui/feed/widgets/video_cover_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _shots =
    '/private/tmp/claude-501/-Volumes-SSD-240GB-EXTERNO-Documentos-Brawe/ac56cc5f-b3cc-4aea-9f4b-e3fd84662a35/scratchpad/shots-video-post';

Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'] ?? '/usr/local/share/flutter';
  final dir = '$root/bin/cache/artifacts/material_fonts';
  Future<void> load(String family, List<String> paths) async {
    final l = FontLoader(family);
    for (final p in paths) {
      l.addFont(File(p).readAsBytes().then((b) => ByteData.sublistView(b)));
    }
    await l.load();
  }

  await load('Roboto', [for (final w in ['Regular', 'Medium', 'Bold', 'Black']) '$dir/Roboto-$w.ttf']);
  await load('MaterialIcons', ['$dir/MaterialIcons-Regular.otf']);
  final cfg = jsonDecode(File('.dart_tool/package_config.json').readAsStringSync()) as Map;
  final pkg = (cfg['packages'] as List).firstWhere((p) => p['name'] == 'lucide_icons_flutter') as Map;
  final uri = pkg['rootUri'] as String;
  final base = uri.startsWith('file://') ? Uri.parse(uri).toFilePath() : Directory('.dart_tool').uri.resolve(uri).toFilePath();
  await load('packages/lucide_icons_flutter/Lucide', ['${base.endsWith('/') ? base : '$base/'}assets/lucide.ttf']);
}

final _boundary = GlobalKey();

Widget _app(Widget home, {bool dark = false, double scale = 1}) => RepaintBoundary(
      key: _boundary,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        locale: const Locale('pt'),
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        builder: (c, w) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
          child: w!,
        ),
        home: home,
      ),
    );

void _size(WidgetTester t, Size s) {
  t.view.physicalSize = s * 2;
  t.view.devicePixelRatio = 2;
  addTearDown(t.view.reset);
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final b = _boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 2);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    File('$_shots/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

/// PNG de gradiente colorido (placeholder de quadro de vídeo).
Future<Uint8List> _frame(int seed, {int w = 90, int h = 160}) async {
  final rec = ui.PictureRecorder();
  final cv = Canvas(rec);
  final hue = (seed * 37) % 360.0;
  final paint = Paint()
    ..shader = ui.Gradient.linear(Offset.zero, Offset(w.toDouble(), h.toDouble()), [
      HSVColor.fromAHSV(1, hue, 0.7, 0.95).toColor(),
      HSVColor.fromAHSV(1, (hue + 60) % 360, 0.8, 0.55).toColor(),
    ]);
  cv.drawRect(Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()), paint);
  final img = await rec.endRecording().toImage(w, h);
  return (await img.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
}

Widget _composer({
  required TextEditingController ctrl,
  bool publishing = false,
  bool withSound = false,
  Uint8List? frame,
  bool empty = false,
}) {
  return Builder(
    builder: (context) => Scaffold(
      backgroundColor: Colors.black54,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.94,
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Material(
            color: Colors.transparent,
            child: VideoComposerView(
              hasVideo: !empty,
              aspectRatio: 9 / 16,
              preview: frame == null
                  ? const SizedBox.shrink()
                  : Image.memory(frame, fit: BoxFit.cover),
              playing: false,
              durationChip: const _Chip(),
              emptyState: Center(child: Text(S.of(context).videoSelect)),
              captionController: ctrl,
              onClose: () {},
              onSwap: () {},
              onTogglePlay: () {},
              onTrim: () {},
              onCover: () {},
              onSound: () {},
              soundActive: withSound,
              publishing: publishing,
              publishLabel: 'Enviando vídeo...',
              progress: publishing ? 1 / 3 : null,
              onPublish: () {},
            ),
          ),
        ),
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
        child: const Text('00:15 / 00:16', style: TextStyle(color: Colors.white, fontSize: 11.5)),
      );
}

Future<void> _settle(WidgetTester t) async {
  await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
  await t.pump(const Duration(milliseconds: 100));
  await t.pump(const Duration(milliseconds: 100));
}

void main() {
  setUpAll(_loadFonts);

  group('VideoCoverTimeline', () {
    test('miniaturas distribuídas pelo centro de cada faixa', () {
      const tl = VideoCoverTimeline(durationMs: 10000);
      expect(tl.thumbTimes(5), [1000, 3000, 5000, 7000, 9000]);
    });

    test('vídeo curto e longo: crescente, dentro do vídeo', () {
      for (final d in [800, 16000, 180000]) {
        final times = VideoCoverTimeline(durationMs: d).thumbTimes(10);
        expect(times.length, 10);
        expect(times.first, greaterThanOrEqualTo(0));
        expect(times.last, lessThan(d));
        for (var i = 1; i < times.length; i++) {
          expect(times[i], greaterThanOrEqualTo(times[i - 1]));
        }
      }
      expect(const VideoCoverTimeline(durationMs: 0).thumbTimes(5), isEmpty);
    });

    test('fração -> tempo selecionado', () {
      const tl = VideoCoverTimeline(durationMs: 16000);
      expect(tl.timeForFraction(0), 0);
      expect(tl.timeForFraction(0.5), 8000);
      expect(tl.timeForFraction(1), 15999);
      expect(tl.timeForFraction(2), 15999);
      expect(tl.timeForFraction(-1), 0);
    });

    test('dx -> fração e tile mais próximo', () {
      expect(VideoCoverTimeline.fractionForDx(50, 100), 0.5);
      expect(VideoCoverTimeline.fractionForDx(-20, 100), 0);
      expect(VideoCoverTimeline.fractionForDx(300, 100), 1);
      expect(VideoCoverTimeline.nearestTile(0.0, 10), 0);
      expect(VideoCoverTimeline.nearestTile(0.55, 10), 5);
      expect(VideoCoverTimeline.nearestTile(1.0, 10), 9);
      expect(VideoCoverTimeline.tileCountFor(320, 35), 10);
      expect(VideoCoverTimeline.tileCountFor(2000, 35), VideoCoverTimeline.maxTiles);
      expect(VideoCoverTimeline.format(75000), '01:15');
    });
  });

  group('legenda', () {
    for (final dark in [false, true]) {
      testWidgets('respeita o tema ${dark ? 'escuro' : 'claro'}', (tester) async {
        final ctrl = TextEditingController();
        await tester.pumpWidget(_app(
          Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: VideoCaptionField(controller: ctrl))),
          dark: dark,
        ));
        final c = tester.element(find.byType(VideoCaptionField)).colors;
        final tf = tester.widget<TextField>(find.byType(TextField));
        expect(tf.decoration!.filled, isFalse);
        expect(tf.style!.color, c.textPrimary);
        expect(tf.decoration!.hintStyle!.color, c.textSecondary);
        expect(find.text('Escreva uma legenda…'), findsOneWidget);
        expect(find.textContaining('opcional'), findsNothing);
        expect(find.text('0/300'), findsOneWidget);
        final box = tester.widget<Container>(find
            .descendant(of: find.byType(VideoCaptionField), matching: find.byType(Container))
            .first);
        expect((box.decoration as BoxDecoration).color, c.surface);
        await tester.enterText(find.byType(TextField), 'Oi');
        await tester.pump();
        expect(find.text('2/300'), findsOneWidget);
      });
    }
  });

  group('compositor sem overflow', () {
    const sizes = {'320x568': Size(320, 568), '390x844': Size(390, 844), '412x915': Size(412, 915)};
    for (final dark in [false, true]) {
      for (final e in sizes.entries) {
        testWidgets('${e.key} ${dark ? 'dark' : 'light'}', (tester) async {
          _size(tester, e.value);
          final frame = await tester.runAsync(() => _frame(3, w: 180, h: 320));
          final ctrl = TextEditingController(text: e.key == '390x844' ? 'Treino de hoje, bora! #brawe' : '');
          await tester.pumpWidget(_app(_composer(ctrl: ctrl, frame: frame, withSound: true), dark: dark));
          await _settle(tester);
          expect(tester.takeException(), isNull);
          await _shot(tester, 'composer-${e.key}-${dark ? 'dark' : 'light'}');
        });
      }
    }

    testWidgets('texto 200% em 320x568', (tester) async {
      _size(tester, const Size(320, 568));
      final frame = await tester.runAsync(() => _frame(5, w: 180, h: 320));
      await tester.pumpWidget(_app(_composer(ctrl: TextEditingController(), frame: frame), scale: 2));
      await _settle(tester);
      expect(tester.takeException(), isNull);
      await _shot(tester, 'composer-320x568-scale200');
    });

    testWidgets('teclado aberto encolhe o preview sem overflow', (tester) async {
      _size(tester, const Size(320, 568));
      tester.view.viewInsets = const FakeViewPadding(bottom: 270 * 2);
      final frame = await tester.runAsync(() => _frame(7, w: 180, h: 320));
      await tester.pumpWidget(_app(_composer(ctrl: TextEditingController(), frame: frame)));
      await _settle(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tablet e estado publicando', (tester) async {
      _size(tester, const Size(820, 1180));
      final frame = await tester.runAsync(() => _frame(9, w: 180, h: 320));
      await tester.pumpWidget(_app(_composer(ctrl: TextEditingController(), frame: frame, publishing: true)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.text('Enviando vídeo...'), findsOneWidget);
      await _shot(tester, 'composer-tablet-publishing');
    });

    testWidgets('sem vídeo (estado vazio)', (tester) async {
      _size(tester, const Size(390, 844));
      await tester.pumpWidget(_app(_composer(ctrl: TextEditingController(), empty: true), dark: true));
      await _settle(tester);
      expect(tester.takeException(), isNull);
    });
  });

  group('seletor de capa', () {
    Widget picker({
      required List<int> seeks,
      required ValueNotifier<int> shown,
      int duration = 16000,
      bool dark = false,
      double scale = 1,
      void Function(CoverPickResult?)? onResult,
    }) {
      return _app(
        Builder(
          builder: (context) => Scaffold(
            backgroundColor: context.colors.surfaceElevated,
            body: VideoCoverPickerSheet(
              videoPath: '/x.mp4',
              durationMs: duration,
              aspectRatio: 9 / 16,
              previewBuilder: (_) => ValueListenableBuilder<int>(
                valueListenable: shown,
                builder: (_, ms, _) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      HSVColor.fromAHSV(1, (ms / duration * 300), .7, .95).toColor(),
                      HSVColor.fromAHSV(1, (ms / duration * 300 + 60) % 360, .8, .5).toColor(),
                    ]),
                  ),
                ),
              ),
              onSeek: (ms) async {
                seeks.add(ms);
                shown.value = ms;
                await Future<void>.delayed(const Duration(milliseconds: 30));
              },
              thumbLoader: (ms) => _frame((ms / duration * 12).round()),
              frameExporter: (ms) async {
                final f = File('${Directory.systemTemp.path}/cover_test_$ms.jpg');
                await f.writeAsBytes([1, 2, 3]);
                return f;
              },
            ),
          ),
        ),
        dark: dark,
        scale: scale,
      );
    }

    for (final dark in [false, true]) {
      testWidgets('arrastar rola o preview e atualiza o tempo (${dark ? 'dark' : 'light'})', (tester) async {
        _size(tester, const Size(390, 844));
        final seeks = <int>[];
        final shown = ValueNotifier<int>(0);
        await tester.pumpWidget(picker(seeks: seeks, shown: shown, dark: dark));
        await _settle(tester);
        await _settle(tester);
        await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 1)));
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull);
        expect(find.text('Capa em 00:00'), findsOneWidget);
        await _shot(tester, 'cover-picker-start-${dark ? 'dark' : 'light'}');

        final strip = find.byType(GestureDetector).evaluate().map((e) => e.widget).length; // sanity
        expect(strip, greaterThan(0));
        final g = tester.getRect(find.byType(LayoutBuilder).last);
        final y = g.center.dy;
        final gesture = await tester.startGesture(Offset(g.left + 30, y));
        for (var i = 1; i <= 10; i++) {
          await gesture.moveTo(Offset(g.left + 30 + (g.width - 60) * i / 10 * 0.6, y));
          await tester.pump(const Duration(milliseconds: 40));
        }
        await gesture.up();
        await tester.pump(const Duration(milliseconds: 200));
        expect(seeks.length, greaterThan(2), reason: 'o vídeo é reposicionado durante o arrasto');
        expect(shown.value, greaterThan(4000));
        expect(shown.value, lessThan(12000));
        expect(find.text('Capa em ${VideoCoverTimeline.format(shown.value)}'), findsOneWidget);
        for (var i = 0; i < 12; i++) {
          await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
          await tester.pump(const Duration(milliseconds: 50));
        }
        await _shot(tester, 'cover-picker-dragged-${dark ? 'dark' : 'light'}');
      });
    }

    testWidgets('confirmar devolve o quadro do tempo escolhido; automática devolve null', (tester) async {
      _size(tester, const Size(390, 844));
      CoverPickResult? got;
      final shown = ValueNotifier<int>(0);
      await tester.pumpWidget(_app(Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                got = await Navigator.of(context).push<CoverPickResult>(MaterialPageRoute(
                  builder: (_) => VideoCoverPickerSheet(
                    videoPath: '/x.mp4',
                    durationMs: 16000,
                    aspectRatio: 9 / 16,
                    initialMs: 8000,
                    previewBuilder: (_) => const SizedBox(),
                    onSeek: (ms) async => shown.value = ms,
                    thumbLoader: (ms) async => null,
                    frameExporter: (ms) async {
                      final f = File('${Directory.systemTemp.path}/cover_test_$ms.jpg');
                      f.writeAsBytesSync([1, 2, 3]);
                      return f;
                    },
                  ),
                ));
              },
              child: const Text('open'),
            ),
          ),
        ),
      )));
      Future<void> flush() async {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 500));
      }

      await tester.tap(find.text('open'));
      await flush();
      expect(shown.value, 8000);
      await tester.tap(find.text('Usar esta capa'));
      for (var i = 0; i < 6; i++) {
        await flush();
      }
      expect(got, isNotNull);
      expect(got!.file!.path, endsWith('cover_test_8000.jpg'));

      got = null;
      await tester.tap(find.text('open'));
      await flush();
      await tester.tap(find.text('Usar capa automática'));
      await flush();
      expect(got, isNotNull);
      expect(got!.file, isNull);
    });

    for (final s in const [Size(320, 568), Size(412, 915)]) {
      testWidgets('sem overflow ${s.width.toInt()}x${s.height.toInt()} 200%', (tester) async {
        _size(tester, s);
        await tester.pumpWidget(picker(seeks: [], shown: ValueNotifier(0), duration: 600, scale: 2));
        await _settle(tester);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('pílula de upload', () {
    const r = VideoUploadRequest(videoPath: '/v.mp4');
    final states = <String, VideoUploadJob>{
      'uploading': const VideoUploadJob(id: 1, request: r, status: VideoUploadStatus.uploading, progress: 0.42),
      'processing': const VideoUploadJob(id: 1, request: r, status: VideoUploadStatus.processing, progress: 0.97),
      'failed': const VideoUploadJob(id: 1, request: r, status: VideoUploadStatus.failed, progress: 0.42, error: VideoUploadError.cover),
      'done': const VideoUploadJob(id: 1, request: r, status: VideoUploadStatus.done, progress: 1, postId: 'p1'),
    };
    for (final dark in [false, true]) {
      for (final w in [320.0, 390.0]) {
        testWidgets('${w.toInt()} ${dark ? 'dark' : 'light'}', (tester) async {
          _size(tester, Size(w, 520));
          await tester.pumpWidget(_app(
            Builder(
              builder: (context) => Scaffold(
                body: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    for (final j in states.values)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: VideoUploadPillView(job: j, onCancel: () {}, onRetry: () {}, onDismiss: () {}, onOpen: () {}),
                      ),
                  ]),
                ),
              ),
            ),
            dark: dark,
            scale: w == 320 ? 1.5 : 1,
          ));
          await tester.pump(const Duration(milliseconds: 200));
          expect(tester.takeException(), isNull);
          expect(find.text('Publicando… 42%'), findsOneWidget);
          expect(find.text('Processando…'), findsOneWidget);
          expect(find.text('Tentar de novo'), findsOneWidget);
          expect(find.text('Vídeo publicado'), findsOneWidget);
          await _shot(tester, 'upload-pill-${w.toInt()}-${dark ? 'dark' : 'light'}');
        });
      }
    }
  });
}
