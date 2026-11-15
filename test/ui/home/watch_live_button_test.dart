import 'package:brawe_app/gen/l10n/app_localizations.dart';
import 'package:brawe_app/ui/home/widgets/views/shared/_live_peek.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('botão "Assistir ao vivo" não muda de altura com a animação', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          body: Center(child: WatchLiveButton(onTap: () {})),
        ),
      ),
    );
    final heights = <double>{};
    // Percorre ~2 s de animação (as barras têm ciclos de 500–700 ms).
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      heights.add(tester.getSize(find.byType(WatchLiveButton)).height);
    }
    expect(heights, hasLength(1), reason: 'alturas vistas: $heights');
  });
}
