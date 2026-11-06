import 'package:brawe_app/data/services/gif_service.dart';
import 'package:brawe_app/domain/models/gif_item.dart';
import 'package:brawe_app/gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/core/themes/app_theme.dart';
import 'package:brawe_app/ui/shared/widgets/gif/gif_bubble.dart';
import 'package:brawe_app/ui/shared/widgets/gif/gif_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

GifItem _item(int i) => GifItem(
      id: 'g$i',
      title: 'gif $i',
      previewUrl: 'https://media1.giphy.com/p$i.webp',
      url: 'https://media1.giphy.com/g$i.gif',
      width: 300,
      height: 200,
    );

class _FakeGifs extends GifService {
  _FakeGifs() : super(Dio());
  Object? error;
  List<GifItem> trendingItems = List.generate(6, _item);
  List<GifItem> searchItems = [_item(100)];
  final calls = <String>[];

  @override
  Future<GifPage> trending({int limit = 24, int offset = 0, String? lang}) async {
    calls.add('trending:$offset');
    if (error != null) throw error!;
    return GifPage(items: trendingItems, nextOffset: null);
  }

  @override
  Future<GifPage> search(String q, {int limit = 24, int offset = 0, String? lang}) async {
    calls.add('search:$q:$offset');
    if (error != null) throw error!;
    return GifPage(items: searchItems, nextOffset: null);
  }
}

Widget _app(Widget child, {bool dark = false, _FakeGifs? fake, double textScale = 1}) => ProviderScope(
      overrides: [if (fake != null) gifServiceProvider.overrideWithValue(fake)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        locale: const Locale('pt'),
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        builder: (c, w) => MediaQuery(data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(textScale)), child: w!),
        home: Scaffold(body: child),
      ),
    );

void _size(WidgetTester t, double w) {
  t.view.physicalSize = Size(w * 2, 800 * 2);
  t.view.devicePixelRatio = 2;
  addTearDown(t.view.reset);
}

void main() {
  group('GifPickerSheet', () {
    testWidgets('mostra tendências, atribuição e escolhe um GIF', (t) async {
      _size(t, 390);
      final fake = _FakeGifs();
      GifAttachment? picked;
      await t.pumpWidget(_app(
        Builder(builder: (c) => TextButton(onPressed: () async => picked = await showGifPicker(c), child: const Text('abrir'))),
        fake: fake,
      ));
      await t.tap(find.text('abrir'));
      await t.pump();
      expect(find.byKey(const Key('gif_skeleton')), findsOneWidget);
      await t.pump(const Duration(milliseconds: 50));
      expect(find.byKey(const Key('gif_grid')), findsOneWidget);
      expect(find.text('Powered by GIPHY'), findsOneWidget);
      expect(fake.calls.first, 'trending:0');
      await t.tap(find.bySemanticsLabel('gif 0').first);
      await t.pumpAndSettle();
      expect(picked?.id, 'g0');
      expect(picked?.width, 300);
    });

    testWidgets('busca com debounce de 350 ms (uma chamada só)', (t) async {
      _size(t, 390);
      final fake = _FakeGifs();
      await t.pumpWidget(_app(const GifPickerSheet(), fake: fake));
      await t.pump();
      await t.enterText(find.byKey(const Key('gif_search_field')), 'ga');
      await t.pump(const Duration(milliseconds: 200));
      await t.enterText(find.byKey(const Key('gif_search_field')), 'gato');
      await t.pump(const Duration(milliseconds: 300));
      expect(fake.calls.where((c) => c.startsWith('search')), isEmpty);
      await t.pump(const Duration(milliseconds: 100));
      await t.pump();
      expect(fake.calls.where((c) => c.startsWith('search')).toList(), ['search:gato:0']);
    });

    testWidgets('estado vazio', (t) async {
      _size(t, 390);
      final fake = _FakeGifs()..trendingItems = [];
      await t.pumpWidget(_app(const GifPickerSheet(), fake: fake));
      await t.pump();
      await t.pump();
      expect(find.text('Nenhum GIF encontrado'), findsOneWidget);
    });

    testWidgets('503 -> GIFs indisponíveis; outro erro -> tentar de novo', (t) async {
      _size(t, 390);
      final fake = _FakeGifs()..error = const GifsUnavailableException();
      await t.pumpWidget(_app(const GifPickerSheet(), fake: fake));
      await t.pump();
      await t.pump();
      expect(find.text('GIFs indisponíveis no momento'), findsOneWidget);
      expect(find.text('Tentar de novo'), findsNothing);
    });

    testWidgets('erro genérico -> tentar de novo recarrega', (t) async {
      _size(t, 390);
      final fake2 = _FakeGifs()..error = const GifsException();
      await t.pumpWidget(_app(const GifPickerSheet(), fake: fake2));
      await t.pump();
      await t.pump();
      expect(find.text('Não foi possível carregar os GIFs.'), findsOneWidget);
      fake2.error = null;
      await t.tap(find.text('Tentar de novo'));
      await t.pump();
      await t.pump();
      expect(find.byKey(const Key('gif_grid')), findsOneWidget);
    });

    for (final dark in [false, true]) {
      for (final w in [320.0, 390.0, 800.0]) {
        testWidgets('${dark ? "escuro" : "claro"} $w texto 200% sem overflow', (t) async {
          _size(t, w);
          await t.pumpWidget(_app(const GifPickerSheet(), dark: dark, fake: _FakeGifs(), textScale: 2));
          await t.pump();
          await t.pump();
          expect(t.takeException(), isNull);
        });
      }
    }
  });

  group('GifBubble', () {
    const gif = GifAttachment(id: 'a', url: 'https://media1.giphy.com/a.gif', width: 480, height: 270);
    for (final dark in [false, true]) {
      for (final w in [320.0, 390.0]) {
        testWidgets('${dark ? "escuro" : "claro"} $w sem overflow e respeita largura máx.', (t) async {
          _size(t, w);
          await t.pumpWidget(_app(
            const Padding(padding: EdgeInsets.all(16), child: Align(alignment: Alignment.centerLeft, child: GifBubble(gif: gif))),
            dark: dark,
          ));
          await t.pump();
          expect(t.takeException(), isNull);
          final size = t.getSize(find.byType(GifBubble));
          expect(size.width, lessThanOrEqualTo(220));
          expect(size.width / size.height, closeTo(480 / 270, 0.05));
        });
      }
    }

    testWidgets('toque pausa e mostra o play', (t) async {
      _size(t, 390);
      await t.pumpWidget(_app(const GifBubble(gif: gif)));
      await t.pump();
      expect(find.byIcon(LucideIcons.play), findsNothing);
      await t.tap(find.byType(GifBubble));
      await t.pump();
      expect(find.byIcon(LucideIcons.play), findsOneWidget);
      await t.tap(find.byType(GifBubble));
      await t.pump();
      expect(find.byIcon(LucideIcons.play), findsNothing);
    });

    testWidgets('em coluna estreita (bolha de chat 150 dp) não estoura', (t) async {
      _size(t, 320);
      await t.pumpWidget(_app(const Align(alignment: Alignment.centerRight, child: SizedBox(width: 150, child: GifBubble(gif: gif)))));
      await t.pump();
      expect(t.takeException(), isNull);
      expect(t.getSize(find.byType(GifBubble)).width, lessThanOrEqualTo(150));
    });
  });
}
