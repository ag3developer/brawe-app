import 'package:brawe_app/ui/broadcaster/widgets/broadcaster_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Testes da máquina de estados explícita [BroadcasterState] usada por
/// `BroadcasterScreen` para evitar chamadas nativas de câmera/EGL
/// (RootEncoder) em momentos inválidos — ver
/// `ANDROID_NATIVE_MEDIA_CRASH_FIX_REPORT.md`.
///
/// Não é possível instanciar/testar `_BroadcasterScreenState` diretamente
/// via widget test porque `CameraController` (rtmp_broadcaster) depende de
/// um `MethodChannel` nativo real (câmera + RootEncoder) que não existe no
/// ambiente de teste headless. Estes testes cobrem o contrato público do
/// enum que sustenta as guardas de estado.
void main() {
  group('BroadcasterState', () {
    test('contém todos os estados esperados do ciclo de vida', () {
      const expected = {
        BroadcasterState.idle,
        BroadcasterState.requestingPermissions,
        BroadcasterState.initializing,
        BroadcasterState.previewReady,
        BroadcasterState.startingStream,
        BroadcasterState.streaming,
        BroadcasterState.stopping,
        BroadcasterState.paused,
        BroadcasterState.disposing,
        BroadcasterState.disposed,
        BroadcasterState.error,
      };

      expect(BroadcasterState.values.toSet(), expected);
    });

    test('previewReady é distinto de streaming e paused', () {
      expect(
        BroadcasterState.previewReady,
        isNot(equals(BroadcasterState.streaming)),
      );
      expect(
        BroadcasterState.previewReady,
        isNot(equals(BroadcasterState.paused)),
      );
    });

    test('nomes dos estados são estáveis (usados em logs sanitizados)', () {
      // `_logEvent` usa `state.name` para telemetria sanitizada — uma
      // renomeação acidental do enum quebraria dashboards/alertas sem
      // quebrar a compilação. Este teste documenta o contrato de nomes.
      const expectedNames = [
        'idle',
        'requestingPermissions',
        'initializing',
        'previewReady',
        'startingStream',
        'streaming',
        'stopping',
        'paused',
        'disposing',
        'disposed',
        'error',
      ];

      expect(
        BroadcasterState.values.map((s) => s.name).toList(),
        expectedNames,
      );
    });
  });
}
