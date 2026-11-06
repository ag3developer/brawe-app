import 'package:brawe_app/ui/core/themes/app_theme.dart';
import 'package:brawe_app/ui/feed/widgets/story_composer_screen.dart';
import 'package:brawe_app/ui/feed/widgets/story_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const red = 0xFFFF0000;
const blue = 0xFF0000FF;
const white = 0xFFFFFFFF;

StoryColorSpan sp(int a, int b, [int c = red]) => StoryColorSpan(a, b, c);

void main() {
  group('adjustSpans', () {
    test('insere antes da faixa: desloca', () {
      expect(adjustSpans([sp(2, 5)], 'abcdefg', 'XXabcdefg', caret: 2), [
        sp(4, 7),
      ]);
    });
    test('insere depois da faixa: intacta', () {
      expect(adjustSpans([sp(0, 3)], 'abcdef', 'abcdXef', caret: 5), [
        sp(0, 3),
      ]);
    });
    test('insere na borda: não herda', () {
      expect(adjustSpans([sp(0, 3)], 'abcdef', 'abcXdef', caret: 4), [
        sp(0, 3),
      ]);
      expect(adjustSpans([sp(2, 4)], 'abcdef', 'abXcdef', caret: 3), [
        sp(3, 5),
      ]);
    });
    test('insere dentro: herda a cor', () {
      expect(adjustSpans([sp(1, 5)], 'abcdef', 'abXXcdef', caret: 4), [
        sp(1, 7),
      ]);
    });
    test('caret desambigua aa -> aaa', () {
      expect(adjustSpans([sp(0, 2)], 'aa', 'aaa', caret: 2), [sp(0, 3)]);
    });
    test('apaga atravessando faixas (valores)', () {
      // remove [2,6): faixa A [0,3)->[0,2); faixa B [4,8)->[2,4).
      final r = adjustSpans([sp(0, 3), sp(4, 8, blue)], '0123456789', '016789');
      expect(r, [sp(0, 2), sp(2, 4, blue)]);
    });
    test('apaga faixa inteira', () {
      expect(adjustSpans([sp(2, 4)], 'abcdef', 'abef'), isEmpty);
    });
    test('substitui seleção', () {
      // "cd" (dentro da faixa 1..5) trocado por "Z".
      expect(adjustSpans([sp(1, 5)], 'abcdef', 'abZef'), [sp(1, 4)]);
    });
    test('substitui seleção que cobre a faixa toda', () {
      expect(adjustSpans([sp(2, 4)], 'abcdef', 'abZef'), isEmpty);
    });
    test('funde vizinhas de mesma cor', () {
      expect(normalizeSpans([sp(0, 2), sp(2, 4), sp(4, 6, blue)], 6), [
        sp(0, 4),
        sp(4, 6, blue),
      ]);
    });
    test('apaga o miolo entre duas faixas iguais: funde', () {
      expect(adjustSpans([sp(0, 2), sp(4, 6)], 'aabbcc', 'aacc'), [sp(0, 4)]);
    });
  });

  group('applyColorToRange / sliceSpans', () {
    test('pinta trecho sobre outra faixa', () {
      final r = applyColorToRange([sp(0, 6)], 6, 2, 4, blue);
      expect(r, [sp(0, 2), sp(2, 4, blue), sp(4, 6)]);
    });
    test('cor base limpa o trecho', () {
      final r = applyColorToRange([sp(0, 6)], 6, 2, 4, white, baseValue: white);
      expect(r, [sp(0, 2), sp(4, 6)]);
    });
    test('slice reposiciona', () {
      expect(sliceSpans([sp(2, 5)], 1, 4), [sp(1, 3)]);
    });
  });

  group('controller', () {
    test('buildTextSpan separa trechos', () {
      final c = StoryRichTextController(
        text: 'ola mundo',
        styleFor: (col) => TextStyle(color: col),
        spans: [sp(4, 9, blue)],
      );
      final span = c.buildTextSpan(
        context: _FakeCtx(),
        style: const TextStyle(color: Color(white)),
        withComposing: false,
      );
      final kids = span.children!.cast<TextSpan>();
      expect(kids.map((e) => e.text), ['ola ', 'mundo']);
      expect(kids[0].style, isNull);
      expect(kids[1].style!.color, const Color(blue));
      expect(span.toPlainText(), 'ola mundo');
    });
    test('digitar/apagar mantém as faixas', () {
      final c = StoryRichTextController(
        text: 'ola mundo',
        styleFor: (col) => TextStyle(color: col),
        spans: [sp(4, 9, blue)],
      );
      c.value = const TextEditingValue(
        text: 'XXola mundo',
        selection: TextSelection.collapsed(offset: 2),
      );
      expect(c.spans, [sp(6, 11, blue)]);
      c.value = const TextEditingValue(
        text: 'XXola',
        selection: TextSelection.collapsed(offset: 5),
      );
      expect(c.spans, isEmpty);
    });
    test('pickColor: seleção pinta trecho, cursor vira cor base', () {
      final c = StoryRichTextController(
        text: 'ola mundo',
        styleFor: (col) => TextStyle(color: col),
      );
      c.selection = const TextSelection(baseOffset: 4, extentOffset: 9);
      expect(c.pickColor(blue, baseValue: white), isTrue);
      expect(c.spans, [sp(4, 9, blue)]);
      c.selection = const TextSelection.collapsed(offset: 2);
      expect(c.pickColor(red, baseValue: white), isFalse);
      expect(c.spans, isEmpty);
    });
  });

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';
    final theme = dark ? AppTheme.dark() : AppTheme.light();

    Widget host(Widget child, {double w = 390, double scale = 1}) =>
        MaterialApp(
          theme: theme,
          home: MediaQuery(
            data: MediaQueryData.fromView(
              WidgetsBinding.instance.platformDispatcher.views.first,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: SizedBox(width: w, child: child),
              ),
            ),
          ),
        );

    testWidgets('campo livre sem caixa ($mode)', (tester) async {
      final c = StoryRichTextController(styleFor: (x) => TextStyle(color: x));
      await tester.pumpWidget(
        host(debugStoryComposeField(controller: c, color: const Color(white))),
      );
      final tf = tester.widget<TextField>(find.byType(TextField));
      final d = tf.decoration!;
      expect(d.filled, isFalse);
      for (final b in [
        d.border,
        d.enabledBorder,
        d.focusedBorder,
        d.disabledBorder,
        d.errorBorder,
        d.focusedErrorBorder,
      ]) {
        expect(b, InputBorder.none);
      }
      // O decorator efetivo (já com o tema global aplicado) também é livre.
      final eff = tester
          .widget<InputDecorator>(find.byType(InputDecorator))
          .decoration
          .applyDefaults(theme.inputDecorationTheme);
      expect(eff.filled, isFalse);
      expect(eff.enabledBorder, isNot(isA<OutlineInputBorder>()));
      expect(eff.focusedBorder, isNot(isA<OutlineInputBorder>()));
      expect(find.byType(OutlineInputBorder), findsNothing);
    });

    testWidgets('seleção pinta só o trecho, cursor pinta tudo ($mode)', (
      tester,
    ) async {
      final c = StoryRichTextController(
        text: 'ola mundo',
        styleFor: (x) => TextStyle(color: x),
      );
      Color base = const Color(white);
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, set) => Column(
              children: [
                debugStoryComposeField(controller: c, color: base),
                debugStoryColorPalette(
                  palette: const [Color(white), Color(blue), Color(red)],
                  selected: base,
                  onSelect: (col) {
                    if (!c.pickColor(
                      col.toARGB32(),
                      baseValue: base.toARGB32(),
                    )) {
                      set(() => base = col);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
      c.selection = const TextSelection(baseOffset: 4, extentOffset: 9);
      await tester.pump();
      // Segunda bolinha (azul) da paleta.
      final dots = find.byType(AnimatedContainer);
      await tester.tap(dots.at(1));
      await tester.pump();
      expect(c.spans.length, 1);
      expect(c.spans.first.colorValue, blue);
      expect(base, const Color(white));

      c.selection = const TextSelection.collapsed(offset: 1);
      await tester.pump();
      await tester.tap(dots.at(2));
      await tester.pump();
      expect(base, const Color(red));
      expect(c.spans, isEmpty);
    });

    testWidgets('camada mantém as faixas ($mode)', (tester) async {
      await tester.pumpWidget(
        host(
          debugStoryTextLayer(
            text: 'ola mundo',
            spans: [sp(4, 9, blue)],
            color: const Color(white),
            bgIndex: 2,
          ),
        ),
      );
      final rt = tester.widget<RichText>(find.byType(RichText).first);
      final texts = <TextSpan>[];
      (rt.text as TextSpan).visitChildren((s) {
        if (s is TextSpan && s.text != null) texts.add(s);
        return true;
      });
      expect(texts.map((e) => e.text).join(), 'ola mundo');
      expect(texts.last.style!.color, const Color(blue));
    });

    for (final w in [320.0, 390.0]) {
      testWidgets('sem overflow a ${w.toInt()}px e 200% ($mode)', (
        tester,
      ) async {
        final c = StoryRichTextController(
          text: 'Um texto bem comprido para quebrar linhas no story',
          styleFor: (x) => TextStyle(color: x),
          spans: [sp(3, 8, blue)],
        );
        await tester.pumpWidget(
          host(
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: debugStoryComposeField(
                      controller: c,
                      color: const Color(white),
                      maxWidth: w - 88,
                    ),
                  ),
                ),
                debugStoryColorPalette(
                  palette: const [
                    Color(white),
                    Color(blue),
                    Color(red),
                    Colors.green,
                    Colors.amber,
                    Colors.pink,
                    Colors.black,
                    Colors.cyan,
                  ],
                  selected: const Color(white),
                  onSelect: (_) {},
                ),
              ],
            ),
            w: w,
            scale: 2,
          ),
        );
        final ex = tester.takeException();
        expect(ex, isNull);
      });
    }
  }
}

class _FakeCtx extends Fake implements BuildContext {}
