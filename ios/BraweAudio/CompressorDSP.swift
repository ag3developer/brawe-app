import AVFoundation

/// Implementação de compressor dinâmico via DSP customizado
/// Aplica redução de ganho baseado em threshold + ratio + envelope
class CompressorDSP {
  var threshold: Float = -12.0
  var ratio: Float = 4.0
  var attackTime: Float = 5.0
  var releaseTime: Float = 50.0
  var makeupGain: Float = 4.0
  
  private var gainReduction: Float = 0.0
  private var envelope: Float = 1.0
  
  private let sampleRate = AudioProcessingConstants.sampleRate
  
  /// Coeficientes de suavização para attack/release
  private var attackCoefficient: Float = 0.0
  private var releaseCoefficient: Float = 0.0
  
  /// Flag para indicar se está comprimindo
  private(set) var isActive: Bool = false
  
  init(
    threshold: Float = -12.0,
    ratio: Float = 4.0,
    attackTime: Float = 5.0,
    releaseTime: Float = 50.0,
    makeupGain: Float = 4.0
  ) {
    self.threshold = threshold
    self.ratio = ratio
    self.attackTime = attackTime
    self.releaseTime = releaseTime
    self.makeupGain = makeupGain
    
    updateCoefficients()
  }
  
  /// Atualiza coeficientes de attack/release
  private func updateCoefficients() {
    // Converter tempo (ms) para coeficiente de suavização exponencial
    // coefficient = exp(-2π * Δf / fs)
    // onde Δf = 1/(time_ms * 0.001)
    
    let attackHz = 1.0 / (Double(attackTime) * 0.001)
    let releaseHz = 1.0 / (Double(releaseTime) * 0.001)
    
    attackCoefficient = Float(exp(-2.0 * .pi * attackHz / sampleRate))
    releaseCoefficient = Float(exp(-2.0 * .pi * releaseHz / sampleRate))
  }
  
  /// Processa buffer de áudio com compressão
  /// - Parameter buffer: Buffer de áudio com amostras
  /// - Returns: Buffer processado com compressão aplicada
  func process(_ buffer: [Float]) -> [Float] {
    var output = buffer
    
    for i in 0..<buffer.count {
      let sample = buffer[i]
      
      // 1. Detectar nível de entrada (RMS simplificado)
      let inputLevel = abs(sample)
      
      // 2. Converter para dB
      let inputLevelDb = 20.0 * log10(max(inputLevel, 0.00001))
      
      // 3. Calcular redução de ganho
      let gainReductionDb = calculateGainReduction(inputLevelDb)
      
      // 4. Converter de volta para linear
      let gainReduction = pow(10.0, gainReductionDb / 20.0)
      
      // 5. Suavizar envelope (attack/release)
      if gainReduction < envelope {
        // Attack (mais rápido)
        envelope = attackCoefficient * envelope + (1.0 - attackCoefficient) * gainReduction
      } else {
        // Release (mais lento)
        envelope = releaseCoefficient * envelope + (1.0 - releaseCoefficient) * gainReduction
      }
      
      // 6. Aplicar makeup gain
      let makeupGainLinear = pow(10.0, makeupGain / 20.0)
      
      // 7. Output = input * compressor * makeup
      output[i] = sample * envelope * makeupGainLinear
      
      // Indicador de compressão ativa
      isActive = gainReductionDb < -0.5
    }
    
    return output
  }
  
  /// Calcula redução de ganho em dB
  /// - Parameter inputDb: Nível de entrada em dB
  /// - Returns: Redução de ganho em dB (negativo = redução)
  private func calculateGainReduction(_ inputDb: Float) -> Float {
    // Se abaixo do threshold, sem compressão
    if inputDb < threshold {
      return 0.0
    }
    
    // Acima do threshold: apply compression ratio
    let excessDb = inputDb - threshold
    let compressedExcessDb = excessDb / ratio
    let gainReductionDb = compressedExcessDb - excessDb
    
    return gainReductionDb
  }
  
  /// Atualiza parâmetros do compressor
  func updateParameters(
    threshold: Float,
    ratio: Float,
    attackTime: Float,
    releaseTime: Float,
    makeupGain: Float
  ) {
    self.threshold = threshold.clamp(
      min: AudioProcessingConstants.minCompressorThreshold,
      max: AudioProcessingConstants.maxCompressorThreshold
    )
    self.ratio = ratio.clamp(
      min: AudioProcessingConstants.minCompressionRatio,
      max: AudioProcessingConstants.maxCompressionRatio
    )
    self.attackTime = attackTime.clamp(
      min: AudioProcessingConstants.minAttackTime,
      max: AudioProcessingConstants.maxAttackTime
    )
    self.releaseTime = releaseTime.clamp(
      min: AudioProcessingConstants.minReleaseTime,
      max: AudioProcessingConstants.maxReleaseTime
    )
    self.makeupGain = makeupGain
    
    updateCoefficients()
  }
  
  /// Reset do estado interno
  func reset() {
    gainReduction = 0.0
    envelope = 1.0
    isActive = false
  }
}

// MARK: - Helper Extension

extension Float {
  /// Limita valor entre min e max
  func clamp(min: Float, max: Float) -> Float {
    if self < min { return min }
    if self > max { return max }
    return self
  }
}
