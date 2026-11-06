// Gera PNGs legíveis (fontes reais) das telas de segurança, para revisão
// visual. Saída em SHOTS_DIR (ou no scratchpad padrão). Sem asserts de pixel.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:brawe_app/data/repositories/auth_repository.dart';
import 'package:brawe_app/data/services/auth_service.dart';
import 'package:brawe_app/data/services/storage_service.dart';
import 'package:brawe_app/ui/auth/view_models/login_view_model.dart';
import 'package:brawe_app/ui/auth/widgets/step_up_screen.dart';
import 'package:brawe_app/ui/settings/widgets/security_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'security_test_support.dart';

const _defaultDir =
    '/private/tmp/claude-501/-Volumes-SSD-240GB-EXTERNO-Documentos-Brawe/'
    'ac56cc5f-b3cc-4aea-9f4b-e3fd84662a35/scratchpad/shots-security';

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

class _Auth extends AuthService {
  _Auth() : super(Dio());
}

class _Store extends StorageService {
  _Store() : super(const FlutterSecureStorage());
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
    final home = Platform.environment['HOME']!;
    await _loadFont('packages/lucide_icons_flutter/Lucide', [
      '$home/.pub-cache/hosted/pub.dev/lucide_icons_flutter-3.1.15/assets/lucide.ttf',
    ]);
  });

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';

    testWidgets('devices + history + protect $mode', (tester) async {
      setScreen(tester, 390, 844);
      final key = GlobalKey();
      await tester.pumpWidget(
        securityApp(
          boundaryKey: key,
          dark: dark,
          overrides: securityOverrides(FakeSecurityService()),
          home: const SecurityScreen(),
        ),
      );
      await tester.pumpAndSettle();
      await _shot(tester, key, 'app-devices-$mode');

      await tester.tap(find.text('Histórico').first);
      await tester.pumpAndSettle();
      await _shot(tester, key, 'app-history-$mode');

      await tester.tap(find.text('Proteção'));
      await tester.pumpAndSettle();
      await _shot(tester, key, 'app-protect-tab-$mode');
    });

    testWidgets('protect sheet $mode', (tester) async {
      setScreen(tester, 390, 844);
      final key = GlobalKey();
      await tester.pumpWidget(
        securityApp(
          boundaryKey: key,
          dark: dark,
          overrides: securityOverrides(FakeSecurityService()),
          home: const SecurityScreen(openProtect: true),
        ),
      );
      await tester.pumpAndSettle();
      await _shot(tester, key, 'app-protect-sheet-$mode');
    });

    testWidgets('step-up $mode', (tester) async {
      setScreen(tester, 390, 844);
      final key = GlobalKey();
      await tester.pumpWidget(
        securityApp(
          boundaryKey: key,
          dark: dark,
          overrides: [
            authRepositoryProvider.overrideWithValue(
              AuthRepository(_Auth(), _Store()),
            ),
          ],
          home: const StepUpScreen(
            challenge: StepUpChallenge(
              challengeId: 'c1',
              emailMasked: 'j***@gmail.com',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('stepup-field')), '48');
      await tester.pump();
      await _shot(tester, key, 'app-stepup-$mode');
    });
  }
}
