import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';

/// Configura o [AVAudioSession] (iOS) / AudioFocus (Android) para captura de
/// áudio em LIVE STREAMING.
///
/// Por que isso importa:
/// - O default do iOS para [.playAndRecord] sem mode aplica AGC agressivo,
///   `voiceProcessing` e filtros telefónicos => chiado, eco, abafamento.
/// - `mode: .videoRecording` ativa a chain de áudio nativa de vídeo: anti-vento,
///   ganho controlado, captura full-range 44.1kHz, sem voice-isolation telefônica.
///
/// Esta é a mesma config que o TikTok, Instagram Live e câmera nativa usam.
class BroadcastAudioSession {
  BroadcastAudioSession._();

  static bool _configured = false;

  /// Configura a sessão de áudio para iniciar uma transmissão.
  /// Idempotente — pode ser chamada várias vezes.
  static Future<void> activate() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        // iOS: .playAndRecord permite ouvir áudio (gifts/SFX) ENQUANTO captura
        // o microfone.
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth |
                AVAudioSessionCategoryOptions.allowBluetoothA2dp |
                AVAudioSessionCategoryOptions.defaultToSpeaker |
                AVAudioSessionCategoryOptions.mixWithOthers,
        // ⭐ ESSE é o ajuste que elimina o chiado: usa o pipeline de vídeo,
        // não o de chamada telefônica.
        avAudioSessionMode: AVAudioSessionMode.videoRecording,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions:
            AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
        // Android: força mode de média (não comunicação) para sample rate full.
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.movie,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      ));
      await session.setActive(true);
      _configured = true;
      if (kDebugMode) {
        debugPrint('[BroadcastAudioSession] ✅ Configurada (videoRecording).');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[BroadcastAudioSession] ⚠️ Falha ao configurar: $e\n$st');
      }
    }
  }

  /// Desativa a sessão ao encerrar a transmissão para liberar o áudio do
  /// dispositivo para outras apps / outros widgets do próprio app.
  static Future<void> deactivate() async {
    if (!_configured) return;
    try {
      final session = await AudioSession.instance;
      await session.setActive(false);
      _configured = false;
    } catch (_) {/* silencioso */}
  }
}
