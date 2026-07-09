import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';

/// Modo de processamento de áudio para live streaming.
enum BroadcastAudioMode {
  /// Full-range 44.1kHz sem filtros de voz — ideal para música, ASMR, gameplay.
  /// Mesmo pipeline que a câmera nativa do iOS/Android.
  quality,

  /// AEC (echo cancellation) + supressão de ruído do OS — ideal para conversas,
  /// ambientes barulhentos, voz sem música. Mesmo que chamada de vídeo do FaceTime.
  voice,
}

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
  static BroadcastAudioMode _currentMode = BroadcastAudioMode.quality;

  static BroadcastAudioMode get currentMode => _currentMode;

  /// Configura a sessão de áudio para iniciar uma transmissão.
  /// [mode] define o pipeline:
  /// - [BroadcastAudioMode.quality] → videoRecording (full-range, sem filtros de voz)
  /// - [BroadcastAudioMode.voice]   → voiceChat (AEC + noise suppression do OS)
  static Future<void> activate({
    BroadcastAudioMode mode = BroadcastAudioMode.quality,
  }) async {
    _currentMode = mode;
    try {
      final session = await AudioSession.instance;

      final avMode = mode == BroadcastAudioMode.voice
          ? AVAudioSessionMode
                .voiceChat // AEC + noise suppression
          : AVAudioSessionMode.videoRecording; // full-range, sem filtros

      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.allowBluetoothA2dp |
              AVAudioSessionCategoryOptions.defaultToSpeaker |
              AVAudioSessionCategoryOptions.mixWithOthers,
          avAudioSessionMode: avMode,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions:
              AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: mode == BroadcastAudioMode.voice
                ? AndroidAudioContentType.speech
                : AndroidAudioContentType.movie,
            flags: AndroidAudioFlags.none,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: false,
        ),
      );
      await session.setActive(true);
      _configured = true;
      if (kDebugMode) {
        debugPrint('[BroadcastAudioSession] ✅ Configurada (${mode.name}).');
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
    } catch (_) {
      /* silencioso */
    }
  }
}
