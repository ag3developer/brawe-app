import AVFoundation

/// Constantes para processamento de áudio em tempo real
struct AudioProcessingConstants {
  /// Taxa de amostragem padrão para streaming (44.1kHz)
  static let sampleRate: Double = 44100.0
  
  /// Profundidade de bits (16-bit PCM)
  static let bitDepth: UInt32 = 16
  
  /// Canais (mono)
  static let channels: UInt32 = 1
  
  /// Tamanho do buffer de processamento (1024 amostras)
  static let bufferSize: AVAudioFrameCount = 1024
  
  /// Máximo de tentativas para EQ
  static let maxEQBands: Int = 20
  
  /// Limiar de compressor mínimo (dB)
  static let minCompressorThreshold: Float = -40.0
  
  /// Limiar de compressor máximo (dB)
  static let maxCompressorThreshold: Float = 0.0
  
  /// Ganho de limiter mínimo (dB)
  static let minLimiterGain: Float = -6.0
  
  /// Ganho de limiter máximo (dB)
  static let maxLimiterGain: Float = 0.0
  
  /// Ganho master mínimo (dB)
  static let minMasterGain: Float = -12.0
  
  /// Ganho master máximo (dB)
  static let maxMasterGain: Float = 12.0
  
  /// Tempo de ataque mínimo (ms)
  static let minAttackTime: Float = 1.0
  
  /// Tempo de ataque máximo (ms)
  static let maxAttackTime: Float = 100.0
  
  /// Tempo de release mínimo (ms)
  static let minReleaseTime: Float = 10.0
  
  /// Tempo de release máximo (ms)
  static let maxReleaseTime: Float = 1000.0
  
  /// Ratio mínimo do compressor
  static let minCompressionRatio: Float = 1.0
  
  /// Ratio máximo do compressor
  static let maxCompressionRatio: Float = 16.0
  
  /// Frequências padrão para EQ (Hz)
  static let eqFrequencies: [Float] = [
    63, 125, 250, 500, 1000, 2000, 4000, 8000
  ]
}
