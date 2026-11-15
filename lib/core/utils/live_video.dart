import 'package:video_player/video_player.dart';

/// Ajustes do `video_player` para HLS ao vivo.
///
/// O pacote lê a duração de uma live uma vez só (ao abrir) e TRAVA a posição
/// nesse valor (`_updatePosition` limita à duração). Depois de ir para o
/// ponto ao vivo, `value.position` fica parado para sempre e o vídeo é dado
/// como "terminado": o próximo `play()` volta para o início do trecho
/// disponível (o vídeo "pula"), e quem vigia a posição acha que travou.
extension LiveVideoController on VideoPlayerController {
  /// `play()` sem o salto para o início.
  Future<void> playLive() {
    final v = value;
    if (v.isInitialized &&
        v.duration > Duration.zero &&
        v.position >= v.duration) {
      value = v.copyWith(
        position: v.duration - const Duration(milliseconds: 1),
        isCompleted: false,
      );
    }
    return play();
  }

  /// Posição real do player nativo (sem a trava na duração).
  Future<Duration> livePosition() async => await position ?? value.position;
}
