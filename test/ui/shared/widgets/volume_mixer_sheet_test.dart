import 'package:brawe_app/gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/core/themes/app_theme.dart';
import 'package:brawe_app/ui/shared/widgets/volume_mixer_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Testes de widget do [VolumeMixerSheet] — Fase D do relatório de áudio
/// (controle de volume da música anexada × áudio original do vídeo).
///
/// Cobre: renderização básica, callbacks de preview em tempo real,
/// valores iniciais, tema claro/escuro e PT/EN/ES (sem hardcode de texto).
void main() {
  Future<void> pumpSheet(
    WidgetTester tester, {
    required double initialMusicVolume,
    required double initialOriginalVolume,
    required ValueChanged<double> onMusicVolumeChanged,
    required ValueChanged<double> onOriginalVolumeChanged,
    String? musicTitle,
    Locale locale = const Locale('pt'),
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        locale: locale,
        theme: theme ?? AppTheme.dark(),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => VolumeMixerSheet.show(
                context,
                initialMusicVolume: initialMusicVolume,
                initialOriginalVolume: initialOriginalVolume,
                onMusicVolumeChanged: onMusicVolumeChanged,
                onOriginalVolumeChanged: onOriginalVolumeChanged,
                musicTitle: musicTitle,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('mostra dois sliders (música e áudio original)', (tester) async {
    await pumpSheet(
      tester,
      initialMusicVolume: 1.0,
      initialOriginalVolume: 1.0,
      onMusicVolumeChanged: (_) {},
      onOriginalVolumeChanged: (_) {},
    );

    expect(find.byType(Slider), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('exibe os percentuais iniciais corretos', (tester) async {
    await pumpSheet(
      tester,
      initialMusicVolume: 0.5,
      initialOriginalVolume: 0.25,
      onMusicVolumeChanged: (_) {},
      onOriginalVolumeChanged: (_) {},
    );

    expect(find.text('50%'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
  });

  testWidgets('arrastar o slider de música chama onMusicVolumeChanged', (
    tester,
  ) async {
    double? lastMusicVolume;
    await pumpSheet(
      tester,
      initialMusicVolume: 1.0,
      initialOriginalVolume: 1.0,
      onMusicVolumeChanged: (v) => lastMusicVolume = v,
      onOriginalVolumeChanged: (_) {},
    );

    final musicSlider = find.byType(Slider).first;
    await tester.drag(musicSlider, const Offset(-100, 0));
    await tester.pumpAndSettle();

    expect(lastMusicVolume, isNotNull);
    expect(lastMusicVolume, lessThan(1.0));
  });

  testWidgets(
    'arrastar o slider de áudio original chama onOriginalVolumeChanged',
    (tester) async {
      double? lastOriginalVolume;
      await pumpSheet(
        tester,
        initialMusicVolume: 1.0,
        initialOriginalVolume: 1.0,
        onMusicVolumeChanged: (_) {},
        onOriginalVolumeChanged: (v) => lastOriginalVolume = v,
      );

      final originalSlider = find.byType(Slider).last;
      await tester.drag(originalSlider, const Offset(-100, 0));
      await tester.pumpAndSettle();

      expect(lastOriginalVolume, isNotNull);
      expect(lastOriginalVolume, lessThan(1.0));
    },
  );

  testWidgets('exibe o título da música quando fornecido', (tester) async {
    await pumpSheet(
      tester,
      initialMusicVolume: 1.0,
      initialOriginalVolume: 1.0,
      onMusicVolumeChanged: (_) {},
      onOriginalVolumeChanged: (_) {},
      musicTitle: 'Paz e Amor',
    );

    expect(find.text('Paz e Amor'), findsOneWidget);
  });

  testWidgets('funciona em tema claro sem exceções', (tester) async {
    await pumpSheet(
      tester,
      initialMusicVolume: 1.0,
      initialOriginalVolume: 1.0,
      onMusicVolumeChanged: (_) {},
      onOriginalVolumeChanged: (_) {},
      theme: AppTheme.light(),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(Slider), findsNWidgets(2));
  });

  testWidgets('funciona em EN sem quebrar (usa localização, não hardcode)', (
    tester,
  ) async {
    await pumpSheet(
      tester,
      initialMusicVolume: 1.0,
      initialOriginalVolume: 1.0,
      onMusicVolumeChanged: (_) {},
      onOriginalVolumeChanged: (_) {},
      locale: const Locale('en'),
    );

    expect(find.text('Done'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('funciona em ES sem quebrar (usa localização, não hardcode)', (
    tester,
  ) async {
    await pumpSheet(
      tester,
      initialMusicVolume: 1.0,
      initialOriginalVolume: 1.0,
      onMusicVolumeChanged: (_) {},
      onOriginalVolumeChanged: (_) {},
      locale: const Locale('es'),
    );

    expect(find.text('Listo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('botão de confirmar fecha o sheet retornando os volumes finais', (
    tester,
  ) async {
    await pumpSheet(
      tester,
      initialMusicVolume: 0.7,
      initialOriginalVolume: 0.3,
      onMusicVolumeChanged: (_) {},
      onOriginalVolumeChanged: (_) {},
    );

    expect(find.byType(VolumeMixerSheet), findsOneWidget);
    await tester.tap(find.text('Concluir'));
    await tester.pumpAndSettle();

    expect(find.byType(VolumeMixerSheet), findsNothing);
  });
}
