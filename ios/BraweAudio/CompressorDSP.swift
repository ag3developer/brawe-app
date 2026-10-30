import Accelerate

/// Compressor dinâmico usando vDSP (Accelerate framework) para performance.
///
/// Corrigido vs versão anterior:
/// 1. vDSP_rmsqv para RMS por bloco (em vez de abs() sample-by-sample)
/// 2. Makeup gain fora do loop de samples (cálculo único, não por sample)
/// 3. Coeficientes de envelope corretos para taxa de amostragem real
/// 4. Threshold em amplitude linear (não dB) para evitar log10 por sample
class CompressorDSP {
  var threshold: Float = -12.0      // dB
  var ratio: Float = 4.0
  var attackTime: Float = 5.0       // ms
  var releaseTime: Float = 50.0     // ms
  var makeupGain: Float = 4.0       // dB

  private var envelope: Float = 1.0
  private var attackCoeff: Float = 0.0
  private var releaseCoeff: Float = 0.0
  private var thresholdLinear: Float = 1.0
  private var makeupGainLinear: Float = 1.0

  private var sampleRate: Float

  init(
    threshold: Float = -12.0,
    ratio: Float = 4.0,
    attackTime: Float = 5.0,
    releaseTime: Float = 50.0,
    makeupGain: Float = 4.0,
    sampleRate: Float = 44100.0
  ) {
    self.sampleRate = sampleRate
    self.threshold = threshold
    self.ratio = ratio
    self.attackTime = attackTime
    self.releaseTime = releaseTime
    self.makeupGain = makeupGain
    updateCoefficients()
  }

  private func updateCoefficients() {
    // Coeficiente de suavização exponencial: 1 - exp(-1 / (time_s * sr))
    let attackSamples  = (attackTime  / 1000.0) * sampleRate
    let releaseSamples = (releaseTime / 1000.0) * sampleRate
    attackCoeff  = 1.0 - exp(-1.0 / max(attackSamples,  1.0))
    releaseCoeff = 1.0 - exp(-1.0 / max(releaseSamples, 1.0))

    // Pre-calculados em linear para evitar pow/log no processamento
    thresholdLinear = pow(10.0, threshold / 20.0)
    makeupGainLinear = pow(10.0, makeupGain / 20.0)
  }

  /// Processa buffer in-place usando vDSP para performance máxima.
  func processInPlace(_ samples: UnsafeMutablePointer<Float>, count: Int) {
    guard count > 0 else { return }

    // 1. Calcular RMS do bloco via vDSP (uma chamada, sem loop)
    var rms: Float = 0.0
    vDSP_rmsqv(samples, 1, &rms, vDSP_Length(count))
    let level = max(rms, 1e-6)  // evitar log(0)

    // 2. Calcular ganho de compressão (em linear)
    let gainReduction: Float
    if level > thresholdLinear {
      // Quantidade de compressão: (1/ratio - 1) * (level - threshold) em dB
      let levelDb = 20.0 * log10(level / thresholdLinear)
      let gainDb  = levelDb * (1.0 / ratio - 1.0)   // negativo = redução
      gainReduction = pow(10.0, gainDb / 20.0)       // [0..1]
    } else {
      gainReduction = 1.0  // abaixo do threshold: sem compressão
    }

    // 3. Suavizar envelope (attack quando comprimindo, release quando
    //    relaxando). O envelope anda UMA vez por bloco de `count` amostras,
    //    então o coeficiente por amostra precisa ser elevado ao tamanho do
    //    bloco — antes o attack de 5 ms virava ~5 s e o compressor quase
    //    não agia (e "bombeava").
    let perSample = gainReduction < envelope ? attackCoeff : releaseCoeff
    let coeff = 1.0 - pow(1.0 - perSample, Float(count))
    envelope += coeff * (gainReduction - envelope)

    // 4. Ganho final = envelope * makeup, aplicado via vDSP_vsmul (1 call)
    var finalGain = envelope * makeupGainLinear
    vDSP_vsmul(samples, 1, &finalGain, samples, 1, vDSP_Length(count))
  }

  func updateParameters(
    threshold: Float, ratio: Float,
    attackTime: Float, releaseTime: Float, makeupGain: Float
  ) {
    self.threshold   = threshold.clamped(to: -40...0)
    self.ratio       = ratio.clamped(to: 1...16)
    self.attackTime  = attackTime.clamped(to: 1...100)
    self.releaseTime = releaseTime.clamped(to: 10...1000)
    self.makeupGain  = makeupGain
    updateCoefficients()
  }

  func reset() {
    envelope = 1.0
  }

  /// Ajusta à taxa de amostragem real do microfone (44,1/48 kHz).
  func setSampleRate(_ rate: Float) {
    guard rate > 0, rate != sampleRate else { return }
    sampleRate = rate
    updateCoefficients()
  }
}

extension Float {
  func clamped(to range: ClosedRange<Float>) -> Float {
    return min(max(self, range.lowerBound), range.upperBound)
  }
}
