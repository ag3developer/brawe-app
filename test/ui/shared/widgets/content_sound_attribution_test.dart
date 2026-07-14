import 'package:brawe_app/gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/core/themes/app_theme.dart';
import 'package:brawe_app/ui/shared/widgets/content_sound_attribution.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Testes de widget do componente único de atribuição musical, usado em
/// Stories, Reels, vídeos e posts com música do Brawe Sounds.
///
/// Cobre: exibição básica, título/artista longos, música indisponível,
/// áudio original, tap para abrir detalhes, tema claro/escuro, PT/EN/ES,
/// e redução de movimento (não deve crashar nem manter animação rodando).
void main() {
  Future<void> pump(
    WidgetTester tester, {
    required Widget child,
    Locale locale = const Locale('pt'),
    ThemeData? theme,
    bool disableAnimations = false,
  }) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          locale: locale,
          theme: theme ?? AppTheme.light(),
          home: Scaffold(body: Center(child: child)),
        ),
      ),
    );
  }

  group('exibição básica', () {
    testWidgets('mostra título e artista em uma linha', (tester) async {
      await pump(
        tester,
        child: const ContentSoundAttribution(
          trackId: 'sound-1',
          title: 'Paz e Amor',
          artistName: 'MC Bia',
        ),
      );

      expect(find.textContaining('Paz e Amor'), findsOneWidget);
      expect(find.textContaining('MC Bia'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sem artistName não quebra e omite o "· Artista"', (
      tester,
    ) async {
      await pump(
        tester,
        child: const ContentSoundAttribution(
          trackId: 'sound-1',
          title: 'Paz e Amor',
        ),
      );

      expect(find.text('Paz e Amor'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('título e artista longos truncam com ellipsis (1 linha)', (
      tester,
    ) async {
      await pump(
        tester,
        child: const SizedBox(
          width: 150,
          child: ContentSoundAttribution(
            trackId: 'sound-1',
            title:
                'Um título extremamente longo que não deveria quebrar o layout',
            artistName:
                'Um nome de artista também absurdamente longo para testar overflow',
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text).first);
      expect(textWidget.maxLines, 1);
      expect(textWidget.overflow, TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);
    });
  });

  group('áudio original', () {
    testWidgets('mostra "Áudio original" em vez do título/artista', (
      tester,
    ) async {
      await pump(
        tester,
        child: const ContentSoundAttribution(
          trackId: 'post-1',
          title: 'Qualquer título (ignorado)',
          isOriginalAudio: true,
        ),
      );

      expect(find.textContaining('Áudio original'), findsOneWidget);
      expect(find.textContaining('Qualquer título'), findsNothing);
    });

    testWidgets('não permite tap quando é áudio original', (tester) async {
      var tapped = false;
      await pump(
        tester,
        child: ContentSoundAttribution(
          trackId: 'post-1',
          title: 'X',
          isOriginalAudio: true,
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(ContentSoundAttribution));
      await tester.pump();
      expect(tapped, isFalse);
    });
  });

  group('música indisponível', () {
    testWidgets('mostra "Música indisponível" e não quebra', (tester) async {
      await pump(
        tester,
        child: const ContentSoundAttribution(
          trackId: 'sound-removed',
          title: 'Faixa Removida',
          artistName: 'Artista X',
          isUnavailable: true,
        ),
      );

      expect(find.textContaining('Música indisponível'), findsOneWidget);
      expect(find.textContaining('Faixa Removida'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('não permite tap quando indisponível', (tester) async {
      var tapped = false;
      await pump(
        tester,
        child: ContentSoundAttribution(
          trackId: 'sound-removed',
          title: 'X',
          isUnavailable: true,
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(ContentSoundAttribution));
      await tester.pump();
      expect(tapped, isFalse);
    });
  });

  group('interação', () {
    testWidgets('tap chama onTap quando disponível', (tester) async {
      var tapped = false;
      await pump(
        tester,
        child: ContentSoundAttribution(
          trackId: 'sound-1',
          title: 'Paz e Amor',
          artistName: 'MC Bia',
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(ContentSoundAttribution));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('tema', () {
    testWidgets('renderiza sem erro em tema claro', (tester) async {
      await pump(
        tester,
        theme: AppTheme.light(),
        child: const ContentSoundAttribution(
          trackId: 'sound-1',
          title: 'Paz e Amor',
          artistName: 'MC Bia',
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renderiza sem erro em tema escuro', (tester) async {
      await pump(
        tester,
        theme: AppTheme.dark(),
        child: const ContentSoundAttribution(
          trackId: 'sound-1',
          title: 'Paz e Amor',
          artistName: 'MC Bia',
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('sobre mídia (Story) usa texto branco por padrão', (
      tester,
    ) async {
      await pump(
        tester,
        theme: AppTheme.dark(),
        child: const ContentSoundAttribution(
          trackId: 'sound-1',
          title: 'Paz e Amor',
          artistName: 'MC Bia',
          contentType: ContentSoundSurface.story,
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text).first);
      expect(textWidget.style?.color, Colors.white);
    });
  });

  group('internacionalização', () {
    testWidgets('PT: Áudio original', (tester) async {
      await pump(
        tester,
        locale: const Locale('pt'),
        child: const ContentSoundAttribution(
          trackId: 'x',
          title: 'x',
          isOriginalAudio: true,
        ),
      );
      expect(find.textContaining('Áudio original'), findsOneWidget);
    });

    testWidgets('EN: Original audio', (tester) async {
      await pump(
        tester,
        locale: const Locale('en'),
        child: const ContentSoundAttribution(
          trackId: 'x',
          title: 'x',
          isOriginalAudio: true,
        ),
      );
      expect(find.textContaining('Original audio'), findsOneWidget);
    });

    testWidgets('ES: Audio original', (tester) async {
      await pump(
        tester,
        locale: const Locale('es'),
        child: const ContentSoundAttribution(
          trackId: 'x',
          title: 'x',
          isOriginalAudio: true,
        ),
      );
      expect(find.textContaining('Audio original'), findsOneWidget);
    });

    testWidgets('PT: Música indisponível', (tester) async {
      await pump(
        tester,
        locale: const Locale('pt'),
        child: const ContentSoundAttribution(
          trackId: 'x',
          title: 'x',
          isUnavailable: true,
        ),
      );
      expect(find.textContaining('Música indisponível'), findsOneWidget);
    });

    testWidgets('EN: Sound unavailable', (tester) async {
      await pump(
        tester,
        locale: const Locale('en'),
        child: const ContentSoundAttribution(
          trackId: 'x',
          title: 'x',
          isUnavailable: true,
        ),
      );
      expect(find.textContaining('Sound unavailable'), findsOneWidget);
    });

    testWidgets('ES: Sonido no disponible', (tester) async {
      await pump(
        tester,
        locale: const Locale('es'),
        child: const ContentSoundAttribution(
          trackId: 'x',
          title: 'x',
          isUnavailable: true,
        ),
      );
      expect(find.textContaining('Sonido no disponible'), findsOneWidget);
    });
  });

  group('acessibilidade / redução de movimento', () {
    testWidgets('respeita disableAnimations sem crashar quando tocando', (
      tester,
    ) async {
      await pump(
        tester,
        disableAnimations: true,
        child: const ContentSoundAttribution(
          trackId: 'sound-1',
          title: 'Paz e Amor',
          artistName: 'MC Bia',
          isPlaying: true,
        ),
      );

      expect(tester.takeException(), isNull);
      // Nenhum AnimationController deve ficar "ticking" com reduced motion.
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });

    testWidgets('expõe Semantics com label da música', (tester) async {
      await pump(
        tester,
        child: const ContentSoundAttribution(
          trackId: 'sound-1',
          title: 'Paz e Amor',
          artistName: 'MC Bia',
          isPlaying: true,
        ),
      );

      final semantics = tester.getSemantics(
        find.byType(ContentSoundAttribution),
      );
      expect(semantics.label, contains('Paz e Amor'));
      expect(semantics.label, contains('Tocando agora'));
    });
  });

  group('ciclo de vida', () {
    testWidgets('dispose não deixa exceptions pendentes', (tester) async {
      await pump(
        tester,
        child: const ContentSoundAttribution(
          trackId: 'sound-1',
          title: 'Paz e Amor',
          artistName: 'MC Bia',
          isPlaying: true,
        ),
      );

      // Remove o widget da árvore (simula fechar Story/sair da tela).
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('alternar isPlaying true->false não crasha', (tester) async {
      await pump(
        tester,
        child: const ContentSoundAttribution(
          trackId: 'sound-1',
          title: 'Paz e Amor',
          artistName: 'MC Bia',
          isPlaying: true,
        ),
      );
      await pump(
        tester,
        child: const ContentSoundAttribution(
          trackId: 'sound-1',
          title: 'Paz e Amor',
          artistName: 'MC Bia',
          isPlaying: false,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
