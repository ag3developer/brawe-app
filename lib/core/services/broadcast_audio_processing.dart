import 'package:flutter/foundation.dart';

/// Presets de equalização profissionais para streaming de áudio.
enum AudioEQPreset {
  /// Flat - sem processamento (baseline)
  flat,

  /// Voice Enhancement - realça frequências de voz (3-5kHz)
  /// Ideal para podcasts, entrevistas, conversas
  voiceEnhancement,

  /// Music Boost - amplifica lows (bass) e highs (treble)
  /// Ideal para streamers que tocam música, DJ
  musicBoost,

  /// Gaming - realça mids (500Hz-2kHz) para diálogos de game + efeitos
  /// Ideal para streamers de games
  gaming,

  /// Podcast - suave realce de voz + suavização de sibilantes
  /// Ideal para streamers que falam muito (educadores, streamers conversadores)
  podcast,

  /// Studio - processamento minimalista com apenas suavização de freqs altas
  /// Ideal para perfeccionistas que querem controle máximo
  studio,
}

/// Parâmetros de compressor para controle de dinâmica
class CompressorConfig {
  final double threshold; // dB (-40 a 0)
  final double ratio; // 1:1 a 8:1
  final double attackTime; // ms
  final double releaseTime; // ms
  final double makeupGain; // dB (0 a 24)

  const CompressorConfig({
    required this.threshold,
    required this.ratio,
    required this.attackTime,
    required this.releaseTime,
    required this.makeupGain,
  });

  /// Compressor light - suave, transparente
  factory CompressorConfig.light() => const CompressorConfig(
    threshold: -18,
    ratio: 2,
    attackTime: 10,
    releaseTime: 100,
    makeupGain: 2,
  );

  /// Compressor medium - balanceado, versatile
  factory CompressorConfig.medium() => const CompressorConfig(
    threshold: -12,
    ratio: 4,
    attackTime: 5,
    releaseTime: 50,
    makeupGain: 4,
  );

  /// Compressor aggressive - controle forte da dinâmica
  factory CompressorConfig.aggressive() => const CompressorConfig(
    threshold: -6,
    ratio: 8,
    attackTime: 1,
    releaseTime: 20,
    makeupGain: 6,
  );
}

/// Parâmetros de equalização por banda de frequência
class EQBand {
  final double frequency; // Hz
  final double gain; // dB (-12 a +12)
  final double q; // Q factor (fator de largura)

  const EQBand({required this.frequency, required this.gain, this.q = 1.0});
}

/// Preset de equalização com múltiplas bandas
class EQPresetConfig {
  final AudioEQPreset preset;
  final String name;
  final String description;
  final List<EQBand> bands;

  const EQPresetConfig({
    required this.preset,
    required this.name,
    required this.description,
    required this.bands,
  });

  /// Factory para criar presets profissionais
  factory EQPresetConfig.fromPreset(AudioEQPreset preset) {
    switch (preset) {
      case AudioEQPreset.flat:
        return EQPresetConfig(
          preset: preset,
          name: 'Flat',
          description: 'Sem processamento',
          bands: const [],
        );

      case AudioEQPreset.voiceEnhancement:
        return EQPresetConfig(
          preset: preset,
          name: 'Voice Enhancement',
          description: 'Realça voz clara e presente',
          bands: const [
            EQBand(frequency: 100, gain: -2, q: 1.0), // Reduz rumble
            EQBand(frequency: 500, gain: 1, q: 1.0), // Warmth
            EQBand(frequency: 2000, gain: 4, q: 1.5), // Presença
            EQBand(frequency: 4000, gain: 3, q: 1.0), // Claridade
            EQBand(frequency: 8000, gain: -1, q: 1.0), // Suaviza sibilantes
          ],
        );

      case AudioEQPreset.musicBoost:
        return EQPresetConfig(
          preset: preset,
          name: 'Music Boost',
          description: 'Amplifica baixos e agudos',
          bands: const [
            EQBand(frequency: 60, gain: 4, q: 1.0), // Bass boost
            EQBand(frequency: 250, gain: 2, q: 1.0), // Bass warmth
            EQBand(frequency: 1000, gain: -1, q: 1.0), // Reduces muddiness
            EQBand(frequency: 4000, gain: 2, q: 1.0), // Treble presence
            EQBand(frequency: 10000, gain: 3, q: 1.0), // Treble sparkle
          ],
        );

      case AudioEQPreset.gaming:
        return EQPresetConfig(
          preset: preset,
          name: 'Gaming',
          description: 'Realça diálogos e efeitos',
          bands: const [
            EQBand(frequency: 100, gain: 0, q: 1.0),
            EQBand(frequency: 500, gain: 2, q: 1.0), // Mids presence
            EQBand(frequency: 2000, gain: 3, q: 1.5), // Dialogue clarity
            EQBand(frequency: 4000, gain: 2, q: 1.0), // Effect details
            EQBand(frequency: 8000, gain: 1, q: 1.0), // Treble
          ],
        );

      case AudioEQPreset.podcast:
        return EQPresetConfig(
          preset: preset,
          name: 'Podcast',
          description: 'Voz clara e profissional',
          bands: const [
            EQBand(frequency: 80, gain: -2, q: 1.0), // Reduz rumble
            EQBand(frequency: 300, gain: 2, q: 1.0), // Warmth
            EQBand(frequency: 1000, gain: 0, q: 1.0),
            EQBand(frequency: 3000, gain: 3, q: 1.5), // Presence
            EQBand(frequency: 7000, gain: -2, q: 1.0), // Sibilant control
            EQBand(frequency: 12000, gain: -1, q: 1.0), // Smooth highs
          ],
        );

      case AudioEQPreset.studio:
        return EQPresetConfig(
          preset: preset,
          name: 'Studio',
          description: 'Processamento minimalista',
          bands: const [
            EQBand(frequency: 50, gain: -1, q: 1.0), // Subsonic roll-off
            EQBand(frequency: 10000, gain: -0.5, q: 1.0), // Gentle air control
          ],
        );
    }
  }
}

/// Serviço de processamento de áudio profissional para RTMP streaming.
///
/// Fornece:
/// - Equalização com múltiplas bandas por preset
/// - Compressão de dinâmica com attack/release
/// - Gain makeup automático
/// - Visualização de espectro (via callback)
///
/// Integra com [BroadcastAudioSession] para processamento nativo no iOS/Android.
class BroadcastAudioProcessing {
  BroadcastAudioProcessing._();

  static AudioEQPreset _currentPreset = AudioEQPreset.voiceEnhancement;
  static CompressorConfig _compressorConfig = CompressorConfig.light();
  static bool _compressorEnabled = true;
  static double _masterGain = 0.0; // dB
  static double _limiterThreshold = 0.0; // dB (-3 a 0)

  // Callbacks para UI (usados na visualização em tempo real)
  // ignore: unused_field
  static Function(List<double> spectrum)? _onSpectrumUpdate;
  // ignore: unused_field
  static Function(double level)? _onLevelUpdate;

  static AudioEQPreset get currentPreset => _currentPreset;
  static CompressorConfig get compressorConfig => _compressorConfig;
  static bool get compressorEnabled => _compressorEnabled;
  static double get masterGain => _masterGain;
  static double get limiterThreshold => _limiterThreshold;

  /// Ativa um preset de equalização profissional
  static Future<void> setPreset(AudioEQPreset preset) async {
    _currentPreset = preset;
    final config = EQPresetConfig.fromPreset(preset);

    if (kDebugMode) {
      debugPrint(
        '[BroadcastAudioProcessing] 🎛️ Preset aplicado: ${config.name}',
      );
      for (final band in config.bands) {
        debugPrint(
          '  • ${band.frequency}Hz: ${band.gain > 0 ? '+' : ''}${band.gain.toStringAsFixed(1)}dB (Q=${band.q})',
        );
      }
    }

    // TODO: Enviar configuração para native layer (iOS AVAudioEngine / Android AAudio)
    // await _applyEQToAudioEngine(config);
  }

  /// Alterna compressor on/off
  static Future<void> toggleCompressor(bool enabled) async {
    _compressorEnabled = enabled;
    if (kDebugMode) {
      debugPrint(
        '[BroadcastAudioProcessing] 🔧 Compressor: ${enabled ? 'ON' : 'OFF'}',
      );
    }
    // TODO: Enviar para native layer
  }

  /// Define configuração de compressor (Light/Medium/Aggressive)
  static Future<void> setCompressor(CompressorConfig config) async {
    _compressorConfig = config;
    if (kDebugMode) {
      debugPrint(
        '[BroadcastAudioProcessing] 🔧 Compressor: '
        'Threshold=${config.threshold}dB, Ratio=${config.ratio}:1, '
        'Attack=${config.attackTime}ms, Release=${config.releaseTime}ms',
      );
    }
    // TODO: Enviar para native layer
  }

  /// Define o master gain da stream (0 a ±12dB)
  static Future<void> setMasterGain(double gainDb) async {
    _masterGain = gainDb.clamp(-12.0, 12.0);
    if (kDebugMode) {
      debugPrint(
        '[BroadcastAudioProcessing] 🔊 Master Gain: ${_masterGain > 0 ? '+' : ''}${_masterGain.toStringAsFixed(1)}dB',
      );
    }
    // TODO: Enviar para native layer
  }

  /// Define limiter de pico para proteção contra clipping (recomendado: -3dB)
  static Future<void> setLimiterThreshold(double thresholdDb) async {
    _limiterThreshold = thresholdDb.clamp(-6.0, 0.0);
    if (kDebugMode) {
      debugPrint(
        '[BroadcastAudioProcessing] 🛡️ Limiter: ${_limiterThreshold.toStringAsFixed(1)}dB',
      );
    }
    // TODO: Enviar para native layer
  }

  /// Registra callback para visualização de espectro em tempo real
  static void onSpectrumUpdate(Function(List<double> spectrum) callback) {
    _onSpectrumUpdate = callback;
  }

  /// Registra callback para nível de áudio em tempo real (0-1)
  static void onLevelUpdate(Function(double level) callback) {
    _onLevelUpdate = callback;
  }

  /// Obtém informações sobre o preset atual
  static EQPresetConfig get currentPresetConfig {
    return EQPresetConfig.fromPreset(_currentPreset);
  }

  /// Debug: Exibe configuração atual
  static void debugPrintStatus() {
    final preset = currentPresetConfig;
    if (kDebugMode) {
      debugPrint('''
╔════════════════════════════════════════════════════════════╗
║  🎙️ BRAWE AUDIO PROCESSING - STATUS                         ║
╠════════════════════════════════════════════════════════════╣
║ Preset: ${preset.name}
║ Description: ${preset.description}
║ Master Gain: ${_masterGain > 0 ? '+' : ''}${_masterGain.toStringAsFixed(1)}dB
║ Compressor: ${_compressorEnabled ? 'ON (' : 'OFF ('}${_compressorConfig.threshold}dB, ${_compressorConfig.ratio}:1)
║ Limiter: ${_limiterThreshold.toStringAsFixed(1)}dB
║ EQ Bands: ${preset.bands.length}
╚════════════════════════════════════════════════════════════╝
      ''');
    }
  }

  /// Resetar para defaults
  static Future<void> reset() async {
    _currentPreset = AudioEQPreset.voiceEnhancement;
    _compressorConfig = CompressorConfig.light();
    _compressorEnabled = true;
    _masterGain = 0.0;
    _limiterThreshold = 0.0;
    if (kDebugMode) {
      debugPrint('[BroadcastAudioProcessing] ♻️ Reset para defaults');
    }
  }
}
