import 'package:brawe_app/ui/sounds/view_models/sound_player_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Testes unitários para a lógica PURA de estado/ownership do
/// [SoundPlayerViewModel] — não exercitam o `AudioPlayer` real (que
/// depende de platform channels/plugins nativos e não roda em `flutter
/// test`). Cobrem especificamente as correções da Fase A/B/E/ownership do
/// relatório de áudio:
///
///   - `SoundPlayerState.copyWith` com `owner`/`clearOwner`.
///   - Regras de "quem é o dono atual" replicadas aqui a partir da lógica
///     de `SoundPlayerViewModel.isOwner` (extraída como função pura para
///     ser testável sem instanciar o provider Riverpod + AudioPlayer).
void main() {
  group('SoundPlayerState.copyWith — owner', () {
    test('define um owner explícito', () {
      const state = SoundPlayerState();
      final next = state.copyWith(owner: 'story:1');
      expect(next.owner, 'story:1');
    });

    test('clearOwner=true remove o owner mesmo se owner for passado', () {
      const state = SoundPlayerState(owner: 'story:1');
      final next = state.copyWith(clearOwner: true);
      expect(next.owner, isNull);
    });

    test('sem owner nem clearOwner preserva o owner anterior', () {
      const state = SoundPlayerState(owner: 'story:1');
      final next = state.copyWith(status: SoundPlayerStatus.playing);
      expect(next.owner, 'story:1');
      expect(next.status, SoundPlayerStatus.playing);
    });

    test('owner novo substitui o owner anterior', () {
      const state = SoundPlayerState(owner: 'story:1');
      final next = state.copyWith(owner: 'fullscreen:42');
      expect(next.owner, 'fullscreen:42');
    });
  });

  group('isOwner semantics (regras replicadas de SoundPlayerViewModel)', () {
    // Replica a regra usada em `SoundPlayerViewModel.isOwner`:
    //   state.owner == null || state.owner == owner
    bool isOwner(SoundPlayerOwner? currentOwner, SoundPlayerOwner owner) =>
        currentOwner == null || currentOwner == owner;

    test('sem owner definido, qualquer chamador é considerado dono', () {
      expect(isOwner(null, 'story:1'), isTrue);
      expect(isOwner(null, 'fullscreen:42'), isTrue);
    });

    test('mesmo owner é reconhecido como dono legítimo', () {
      expect(isOwner('story:1', 'story:1'), isTrue);
    });

    test('owner diferente NÃO é reconhecido como dono', () {
      expect(isOwner('story:1', 'fullscreen:42'), isFalse);
    });
  });

  group('SoundPlayerState defaults', () {
    test('estado inicial é idle, sem som, sem owner', () {
      const state = SoundPlayerState();
      expect(state.status, SoundPlayerStatus.idle);
      expect(state.sound, isNull);
      expect(state.owner, isNull);
      expect(state.isPlaying, isFalse);
      expect(state.isLoading, isFalse);
    });

    test('isPlaying somente quando status == playing', () {
      const playing = SoundPlayerState(status: SoundPlayerStatus.playing);
      const paused = SoundPlayerState(status: SoundPlayerStatus.paused);
      expect(playing.isPlaying, isTrue);
      expect(paused.isPlaying, isFalse);
    });

    test('isLoading somente quando status == loading', () {
      const loading = SoundPlayerState(status: SoundPlayerStatus.loading);
      expect(loading.isLoading, isTrue);
      expect(const SoundPlayerState().isLoading, isFalse);
    });
  });
}
