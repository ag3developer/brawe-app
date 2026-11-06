import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:brawe_app/data/repositories/post_repository.dart';
import 'package:brawe_app/domain/models/post.dart';
import 'package:brawe_app/domain/models/post_comment.dart';
import 'package:brawe_app/gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/core/themes/app_theme.dart';
import 'package:brawe_app/ui/feed/view_models/comments_view_model.dart';
import 'package:brawe_app/ui/feed/widgets/comments_sheet.dart';
import 'package:brawe_app/ui/feed/widgets/post_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _shots =
    '/private/tmp/claude-501/-Volumes-SSD-240GB-EXTERNO-Documentos-Brawe/ac56cc5f-b3cc-4aea-9f4b-e3fd84662a35/scratchpad/shots-post-viewer';

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

class _FakeRepo implements PostRepository {
  _FakeRepo();
  bool fail = false;
  final calls = <bool>[]; // wasLiked passado a toggleLike

  @override
  Future<void> toggleLike(String postId, bool isLiked) async {
    calls.add(isLiked);
    if (fail) throw Exception('boom');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final n = invocation.memberName;
    if (n == #getFeed || n == #getFollowingFeed) return Future.value(<Post>[]);
    return Future<dynamic>.value();
  }
}

class _FakeComments extends CommentsViewModel {
  @override
  Future<List<PostComment>> build(String postId) async => [
        PostComment(
          id: 'c1',
          postId: postId,
          authorId: 'u2',
          authorName: 'Ana',
          authorUsername: 'ana',
          content: 'Linda foto',
          likesCount: 0,
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

  @override
  Future<void> addComment(String content, {String? parentId, gif}) async {
    state = AsyncData([
      PostComment(
        id: 'c2',
        postId: postId,
        authorId: 'me',
        authorName: 'Eu',
        authorUsername: 'eu',
        content: content,
        likesCount: 0,
        createdAt: DateTime(2026, 1, 2),
      ),
      ...state.value!,
    ]);
  }
}

Future<MemoryImage> _placeholder() async {
  final rec = ui.PictureRecorder();
  final cv = Canvas(rec);
  const w = 800, h = 1000;
  cv.drawRect(
    Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
    Paint()
      ..shader = ui.Gradient.linear(Offset.zero, Offset(w.toDouble(), h.toDouble()),
          [const Color(0xFFFF8A5B), const Color(0xFF3A2D8F)]),
  );
  final img = await rec.endRecording().toImage(w, h);
  final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))!;
  return MemoryImage(bytes.buffer.asUint8List());
}

final _boundary = GlobalKey();
const _longCaption =
    'Pôr do sol no fim de semana com a galera, melhor dia do ano até agora. '
    'Valeu demais a todo mundo que apareceu e fez essa tarde ser inesquecível, '
    'já estou com saudade e planejando a próxima.';

Widget _host({
  required _FakeRepo repo,
  required MemoryImage image,
  String caption = 'Legenda curta',
  double scale = 1,
  void Function(bool, int)? onLike,
  ValueChanged<int>? onComments,
}) {
  return ProviderScope(
    overrides: [
      postRepositoryProvider.overrideWithValue(repo),
      commentsViewModelProvider('p1').overrideWith(_FakeComments.new),
    ],
    child: RepaintBoundary(
      key: _boundary,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        locale: const Locale('pt'),
        theme: AppTheme.dark(),
        builder: (c, w) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
          child: w!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                key: const Key('open'),
                onPressed: () => Navigator.of(context, rootNavigator: true).push(
                  postImageViewerRoute(
                    PostImageViewer(
                      imageUrl: 'x',
                      imageProvider: image,
                      postId: 'p1',
                      caption: caption,
                      authorName: 'Carlos Martins',
                      authorUsername: 'carlos',
                      initialLiked: false,
                      initialLikesCount: 2,
                      commentsCount: 1,
                      onLikeChanged: onLike ?? (_, _) {},
                      onCommentsCountChanged: onComments,
                    ),
                  ),
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _open(WidgetTester t, Widget host, MemoryImage image) async {
  await t.pumpWidget(host);
  await t.runAsync(() => precacheImage(image, t.element(find.byKey(const Key('open')))));
  await t.tap(find.byKey(const Key('open')));
  await t.pumpAndSettle();
}

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MemoryImage image;

  setUpAll(() async {
    await _loadFonts();
    image = await _placeholder();
  });

  const photo = Key('postViewerPhoto');

  testWidgets('toque duplo curte uma vez, nunca descurte, mostra o coração', (t) async {
    _size(t, const Size(390, 844));
    final repo = _FakeRepo();
    final likes = <(bool, int)>[];
    await _open(t, _host(repo: repo, image: image, onLike: (l, c) => likes.add((l, c))), image);

    expect(find.text('2'), findsOneWidget);
    await t.tap(find.byKey(photo));
    await t.pump(const Duration(milliseconds: 80));
    await t.tap(find.byKey(photo));
    await t.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const Key('postViewerHeartBurst')), findsOneWidget);
    await t.pump(const Duration(milliseconds: 900));
    expect(repo.calls, [false]);
    expect(likes, [(true, 3)]);
    expect(find.text('3'), findsOneWidget);

    // Segundo toque duplo: já curtido -> não descurte.
    await t.tap(find.byKey(photo));
    await t.pump(const Duration(milliseconds: 80));
    await t.tap(find.byKey(photo));
    await t.pump(const Duration(milliseconds: 1200));
    expect(repo.calls, [false]);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('botão de coração alterna e faz rollback em erro', (t) async {
    _size(t, const Size(390, 844));
    final repo = _FakeRepo();
    await _open(t, _host(repo: repo, image: image), image);

    await t.tap(find.byKey(const Key('postViewerLike')));
    await t.pump();
    expect(find.text('3'), findsOneWidget);
    await t.tap(find.byKey(const Key('postViewerLike')));
    await t.pump();
    expect(find.text('2'), findsOneWidget);
    expect(repo.calls, [false, true]);

    repo.fail = true;
    await t.tap(find.byKey(const Key('postViewerLike')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 50));
    expect(find.text('2'), findsOneWidget, reason: 'rollback para 2');
    await t.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('botão de comentário abre a folha e atualiza o contador', (t) async {
    _size(t, const Size(390, 844));
    final seen = <int>[];
    await _open(t, _host(repo: _FakeRepo(), image: image, onComments: seen.add), image);

    await t.tap(find.byKey(const Key('postViewerComment')));
    await t.pumpAndSettle();
    expect(find.byType(CommentsSheet), findsOneWidget);

    final container = ProviderScope.containerOf(t.element(find.byType(CommentsSheet)));
    await container.read(commentsViewModelProvider('p1').notifier).addComment('oi');
    await t.pumpAndSettle();
    expect(seen, [2]);
    await t.pump(const Duration(seconds: 10));
  });

  testWidgets('arrastar além do limite fecha; abaixo volta', (t) async {
    _size(t, const Size(390, 844));
    await _open(t, _host(repo: _FakeRepo(), image: image), image);

    await t.timedDrag(find.byKey(photo), const Offset(0, 50), const Duration(seconds: 1));
    await t.pumpAndSettle();
    expect(find.byType(PostImageViewer), findsOneWidget);
    final box = t.getTopLeft(find.byKey(photo));
    expect(box.dy, closeTo(t.getTopLeft(find.byKey(photo)).dy, 0.1));

    await t.timedDrag(find.byKey(photo), const Offset(0, 220), const Duration(seconds: 1));
    await t.pumpAndSettle();
    expect(find.byType(PostImageViewer), findsNothing);
    expect(find.byKey(const Key('open')), findsOneWidget);
  });

  testWidgets('arrastar para cima também fecha', (t) async {
    _size(t, const Size(390, 844));
    await _open(t, _host(repo: _FakeRepo(), image: image), image);
    await t.timedDrag(find.byKey(photo), const Offset(0, -220), const Duration(seconds: 1));
    await t.pumpAndSettle();
    expect(find.byType(PostImageViewer), findsNothing);
  });

  testWidgets('legenda longa expande com "Mais"', (t) async {
    _size(t, const Size(390, 844));
    await _open(t, _host(repo: _FakeRepo(), image: image, caption: _longCaption), image);
    expect(find.byKey(const Key('postViewerCaptionMore')), findsOneWidget);
    await t.tap(find.byKey(const Key('postViewerCaptionMore')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('postViewerCaptionMore')), findsNothing);
  });

  for (final (size, name) in [
    (const Size(320, 568), '320x568'),
    (const Size(390, 844), '390x844'),
    (const Size(412, 915), '412x915'),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('layout $name x$scale sem overflow', (t) async {
        _size(t, size);
        t.view.padding = const FakeViewPadding(top: 94, bottom: 68); // notch/home indicator
        addTearDown(t.view.resetPadding);
        await _open(t, _host(repo: _FakeRepo(), image: image, caption: _longCaption, scale: scale), image);
        expect(t.takeException(), isNull);
        await _shot(t, 'viewer_${name}_x${scale.toInt()}');
        if (scale == 1.0) {
          await t.tap(find.byKey(const Key('postViewerCaptionMore')));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          await _shot(t, 'viewer_${name}_expanded');
        }
      });
    }
  }

  testWidgets('screenshot: coração do toque duplo', (t) async {
    _size(t, const Size(390, 844));
    await _open(t, _host(repo: _FakeRepo(), image: image), image);
    await t.tap(find.byKey(photo));
    await t.pump(const Duration(milliseconds: 80));
    await t.tap(find.byKey(photo));
    await t.pump(const Duration(milliseconds: 300));
    await _shot(t, 'viewer_double_tap_heart');
    await t.pump(const Duration(seconds: 2));
  });
}
