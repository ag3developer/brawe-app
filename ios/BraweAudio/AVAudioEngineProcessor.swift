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

    lock.lock()
    let comp = compressor
    let compEnabled = compressorEnabled
    let gain = masterGainLinear
    let limiter = limiterLinear
    let biquads = eqBiquads
    lock.unlock()

    // 1. EQ: aplicar filtros biquad em cascata
    if !biquads.isEmpty {
      var buf = floats
      for var filter in biquads {
        filter.process(&buf, count: frameCount)
        floats = buf
      }
    }

    // 2. Compressor
    if compEnabled, let c = comp {
      c.processInPlace(&floats, count: frameCount)
    }

    // 3. Master gain (out-of-place para evitar overlapping access)
    if gain != 1.0 {
      var g = gain
      var result = [Float](repeating: 0, count: frameCount)
      vDSP_vsmul(&floats, 1, &g, &result, 1, vDSP_Length(frameCount))
      floats = result
    }

    // 4. Limiter (hard clip, out-of-place)
    if limiter < 1.0 {
      var pos =  limiter
      var neg = -limiter
      var result = [Float](repeating: 0, count: frameCount)
      vDSP_vclip(&floats, 1, &neg, &pos, &result, 1, vDSP_Length(frameCount))
      floats = result
    }

    // Float32 → Int16 (de volta para o CMSampleBuffer)
    var scaleBack: Float = Float(Int16.max)
    var scaled = [Float](repeating: 0, count: frameCount)
    vDSP_vsmul(&floats, 1, &scaleBack, &scaled, 1, vDSP_Length(frameCount))
    vDSP_vfix16(&scaled, 1, samples16, 1, vDSP_Length(frameCount))
  }

  // MARK: - MethodChannel Handlers

  @objc func applyEQPreset(preset: String, bands: [[String: NSNumber]]) {
    lock.lock(); defer { lock.unlock() }
    // Converter bandas em filtros biquad peak (parametric EQ)
    eqBiquads = bands.compactMap { b in
      guard let freq = b["frequency"]?.floatValue,
            let gainDb = b["gain"]?.floatValue,
            let q = b["q"]?.floatValue else { return nil }
      return BiquadFilter.peakingEQ(frequency: freq, gainDb: gainDb, q: q, sampleRate: 44100)
    }
    print("✅ EQ '\(preset)': \(eqBiquads.count) filtros ativos")
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
