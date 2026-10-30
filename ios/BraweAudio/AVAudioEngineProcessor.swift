import AVFoundation
import Accelerate

/// Processador de áudio para RTMP streaming via CMSampleBuffer.
///
/// ARQUITETURA CORRETA:
/// O rtmp_broadcaster captura via AVCaptureSession e passa CMSampleBuffers
/// diretamente ao HaishinKit. Para processar o áudio ANTES do encoding RTMP,
/// patchamos o FlutterRTMPStreaming.swift para chamar
/// AVAudioEngineProcessor.shared.processCMSampleBuffer() em addAudioData().
///
/// Pipeline: Microfone → AVCaptureSession → [processCMSampleBuffer] → HaishinKit → RTMP
///
/// Processamento aplicado no CMSampleBuffer (in-place, sem cópia extra):
///   1. EQ paramétrico: filtros IIR por banda de frequência (biquad via vDSP)
///   2. Compressor: RMS detection + gain envelope via Accelerate
///   3. Master gain: vDSP_vsmul (1 call)
///   4. Limiter: vDSP_vclip (1 call)
@objc class AVAudioEngineProcessor: NSObject {
  @objc static let shared = AVAudioEngineProcessor()

  // MARK: - State (thread-safe via lock)
  private let lock = NSLock()
  private var compressor: CompressorDSP?
  private var compressorEnabled = true
  private var masterGainLinear: Float = 1.0
  private var limiterLinear: Float = 1.0      // amplitude max (1.0 = 0dBFS)
  private var eqBiquads: [BiquadFilter] = []  // cadeia de filtros EQ
  /// Parâmetros das bandas (para recalcular os coeficientes quando a taxa
  /// de amostragem real do microfone for diferente — iPhone costuma
  /// capturar a 48 kHz; antes estava fixo em 44,1 kHz e as bandas ficavam
  /// ~9% deslocadas).
  private var eqBands: [(frequency: Float, gainDb: Float, q: Float)] = []
  private var eqSampleRate: Float = 0
  private var isSetup = false

  override private init() { super.init() }

  // MARK: - Setup

  @objc func setupAudioEngine() {
    lock.lock(); defer { lock.unlock() }
    guard !isSetup else { return }
    compressor = CompressorDSP()
    isSetup = true
    print("✅ AVAudioEngineProcessor ready")
  }

  // MARK: - CMSampleBuffer Processing (chamado pelo plugin RTMP)

  /// Processa um CMSampleBuffer de áudio in-place antes de enviar ao HaishinKit.
  /// Thread-safe, sem alocações heap no caminho crítico.
  @objc func processCMSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
    guard isSetup else { return }
    guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { return }

    var length = 0
    var dataPointer: UnsafeMutablePointer<Int8>? = nil
    guard CMBlockBufferGetDataPointer(
      blockBuffer, atOffset: 0,
      lengthAtOffsetOut: nil, totalLengthOut: &length,
      dataPointerOut: &dataPointer
    ) == noErr, let raw = dataPointer else { return }

    let desc = CMSampleBufferGetFormatDescription(sampleBuffer)
    let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(desc!)?.pointee
    guard let format = asbd else { return }

    let sampleRate = Float(format.mSampleRate)
    let bytesPerSample = Int(format.mBytesPerFrame)
    guard bytesPerSample == 2 else { return }  // PCM Int16 apenas

    let frameCount = length / bytesPerSample
    guard frameCount > 0 else { return }

    // Trabalhar em Float32 para precisão DSP, depois converter de volta
    let samples16 = raw.withMemoryRebound(to: Int16.self, capacity: frameCount) { $0 }
    var floats = [Float](repeating: 0, count: frameCount)

    // Int16 → Float32 normalizado [-1, 1]  (out-of-place)
    var scale: Float = 1.0 / Float(Int16.max)
    vDSP_vflt16(samples16, 1, &floats, 1, vDSP_Length(frameCount))
    var normalized = [Float](repeating: 0, count: frameCount)
    vDSP_vsmul(&floats, 1, &scale, &normalized, 1, vDSP_Length(frameCount))
    floats = normalized

    // O lock cobre o processamento inteiro: o estado dos filtros e do
    // compressor precisa persistir ENTRE buffers e não pode ser trocado
    // por um preset no meio do bloco. Chamadas do MethodChannel são raras.
    lock.lock()
    let gain = masterGainLinear
    let limiter = limiterLinear

    // 1. EQ: filtros biquad em cascata, processados NO PRÓPRIO array.
    //    Antes `for var filter in biquads` processava uma CÓPIA e o
    //    histórico (x1/x2/y1/y2) era descartado a cada buffer → cliques e
    //    zumbido ~43×/s (pior no reforço de graves).
    if !eqBands.isEmpty {
      if eqSampleRate != sampleRate { rebuildBiquads(sampleRate: sampleRate) }
      for i in eqBiquads.indices {
        eqBiquads[i].process(&floats, count: frameCount)
      }
    }

    // 2. Compressor
    if compressorEnabled, let c = compressor {
      c.setSampleRate(sampleRate)
      c.processInPlace(&floats, count: frameCount)
    }
    lock.unlock()

    // 3. Master gain (out-of-place para evitar overlapping access)
    if gain != 1.0 {
      var g = gain
      var result = [Float](repeating: 0, count: frameCount)
      vDSP_vsmul(&floats, 1, &g, &result, 1, vDSP_Length(frameCount))
      floats = result
    }

    // 4. Limiter / proteção de clip — SEMPRE aplicado. Com EQ +4 dB e
    //    makeup +4 dB o sinal passa de 0 dBFS e o vDSP_vfix16 abaixo não
    //    satura: valores acima do fundo de escala viravam distorção.
    var pos =  min(limiter, 1.0)
    var neg = -pos
    var clipped = [Float](repeating: 0, count: frameCount)
    vDSP_vclip(&floats, 1, &neg, &pos, &clipped, 1, vDSP_Length(frameCount))
    floats = clipped

    // Float32 → Int16 (de volta para o CMSampleBuffer)
    var scaleBack: Float = Float(Int16.max)
    var scaled = [Float](repeating: 0, count: frameCount)
    vDSP_vsmul(&floats, 1, &scaleBack, &scaled, 1, vDSP_Length(frameCount))
    vDSP_vfix16(&scaled, 1, samples16, 1, vDSP_Length(frameCount))
  }

  // MARK: - MethodChannel Handlers

  @objc func applyEQPreset(preset: String, bands: [[String: NSNumber]]) {
    lock.lock(); defer { lock.unlock() }
    // Guarda as bandas; os coeficientes são (re)calculados com a taxa de
    // amostragem real do primeiro buffer (ver processCMSampleBuffer).
    eqBands = bands.compactMap { b in
      guard let freq = b["frequency"]?.floatValue,
            let gainDb = b["gain"]?.floatValue,
            let q = b["q"]?.floatValue else { return nil }
      return (freq, gainDb, q)
    }
    rebuildBiquads(sampleRate: eqSampleRate > 0 ? eqSampleRate : 48000)
    print("✅ EQ '\(preset)': \(eqBiquads.count) filtros ativos")
  }

  /// Recalcula os filtros (chamar com `lock` adquirido).
  private func rebuildBiquads(sampleRate: Float) {
    eqSampleRate = sampleRate
    eqBiquads = eqBands
      .filter { $0.frequency < sampleRate / 2 }
      .map {
        BiquadFilter.peakingEQ(
          frequency: $0.frequency, gainDb: $0.gainDb, q: $0.q,
          sampleRate: sampleRate
        )
      }
  }

  @objc func setCompressor(
    threshold: NSNumber, ratio: NSNumber,
    attackTime: NSNumber, releaseTime: NSNumber, makeupGain: NSNumber
  ) {
    lock.lock(); defer { lock.unlock() }
    compressor?.updateParameters(
      threshold: threshold.floatValue, ratio: ratio.floatValue,
      attackTime: attackTime.floatValue, releaseTime: releaseTime.floatValue,
      makeupGain: makeupGain.floatValue
    )
    print("✅ Compressor: \(threshold)dB \(ratio):1")
  }

  @objc func toggleCompressor(_ enabled: NSNumber) {
    lock.lock(); defer { lock.unlock() }
    compressorEnabled = enabled.boolValue
    if !compressorEnabled { compressor?.reset() }
    print("✅ Compressor: \(compressorEnabled ? "ON" : "OFF")")
  }

  @objc func setMasterGain(_ gainDb: NSNumber) {
    lock.lock(); defer { lock.unlock() }
    masterGainLinear = pow(10.0, gainDb.floatValue.clamped(to: -12...12) / 20.0)
    print("✅ Master Gain: \(gainDb)dB → \(masterGainLinear)x")
  }

  @objc func setLimiterThreshold(_ thresholdDb: NSNumber) {
    lock.lock(); defer { lock.unlock() }
    limiterLinear = pow(10.0, thresholdDb.floatValue.clamped(to: -6...0) / 20.0)
    print("✅ Limiter: \(thresholdDb)dB → \(limiterLinear)x")
  }

  @objc func resetAudio() {
    lock.lock(); defer { lock.unlock() }
    eqBands = []
    eqBiquads = []
    compressor?.reset()
    compressor?.updateParameters(threshold: -12, ratio: 4, attackTime: 5, releaseTime: 50, makeupGain: 4)
    masterGainLinear = 1.0
    limiterLinear = 1.0
    compressorEnabled = true
    print("✅ Audio reset to defaults")
  }

  @objc func shutdown() {
    lock.lock(); defer { lock.unlock() }
    isSetup = false
    eqBands = []
    eqBiquads = []
    print("✅ AVAudioEngineProcessor shutdown")
  }
}

// MARK: - Biquad Filter (EQ paramétrico)

/// Filtro IIR biquad de segunda ordem para EQ paramétrico (peaking EQ).
/// Baseado na fórmula Audio EQ Cookbook de Robert Bristow-Johnson.
struct BiquadFilter {
  // Coeficientes do filtro
  var b0, b1, b2: Float  // numerador
  var a1, a2: Float      // denominador (a0 = 1 normalizado)

  // Estado do filtro (memória de 2 samples)
  var x1: Float = 0; var x2: Float = 0
  var y1: Float = 0; var y2: Float = 0

  /// Cria um filtro peaking EQ (realça ou atenua frequência específica)
  static func peakingEQ(frequency: Float, gainDb: Float, q: Float, sampleRate: Float) -> BiquadFilter {
    let A  = pow(10.0, gainDb / 40.0)  // sqrt(10^(dB/20))
    let w0 = 2.0 * Float.pi * frequency / sampleRate
    let sinW0 = sin(w0)
    let cosW0 = cos(w0)
    let alpha = sinW0 / (2.0 * q)

    let b0 =  1.0 + alpha * A
    let b1 = -2.0 * cosW0
    let b2 =  1.0 - alpha * A
    let a0 =  1.0 + alpha / A
    let a1 = -2.0 * cosW0
    let a2 =  1.0 - alpha / A

    return BiquadFilter(b0: b0/a0, b1: b1/a0, b2: b2/a0, a1: a1/a0, a2: a2/a0)
  }

  /// Processa buffer in-place com Direct Form II Transposed (numericamente estável)
  mutating func process(_ samples: inout [Float], count: Int) {
    for i in 0..<count {
      let x = samples[i]
      let y = b0*x + b1*x1 + b2*x2 - a1*y1 - a2*y2
      x2 = x1; x1 = x
      y2 = y1; y1 = y
      samples[i] = y
    }
  }
}
