import AVFoundation

/// Processador de áudio profissional usando AVAudioEngine
/// Implementa chain real-time: Entrada → EQ → Compressor → Limiter → Saída
@objc class AVAudioEngineProcessor: NSObject {
  @objc static let shared = AVAudioEngineProcessor()

  private let engine = AVAudioEngine()
  // AVAudioUnitEQ inicializado com 8 bandas (índices 0-7)
  private let eqNode = AVAudioUnitEQ(numberOfBands: 8)
  private var compressorDSP: CompressorDSP?

  private var masterGainLinear: Float = 1.0   // amplitude linear (1.0 = 0dB)
  private var limiterThreshold: Float = 1.0   // amplitude linear (1.0 = 0dB)
  private var compressorEnabled: Bool = true

  private var isSetup = false
  private let lock = NSLock()
  
  override private init() {
    super.init()
  }
  
  // MARK: - Setup
  
  /// Configura o engine de áudio para processamento real-time.
  /// Deve ser chamado após a AVAudioSession estar ativa.
  @objc func setupAudioEngine() {
    lock.lock()
    defer { lock.unlock() }

    guard !isSetup else { return }

    // 1. Inicializar EQ flat (gain 0 em todas as bandas)
    setupEQFlat()

    // 2. Inicializar compressor DSP
    compressorDSP = CompressorDSP(
      threshold: -12.0,
      ratio: 4.0,
      attackTime: 5.0,
      releaseTime: 50.0,
      makeupGain: 4.0
    )

    // 3. Atacher nó EQ ao engine
    engine.attach(eqNode)

    // 4. Obter o inputNode (microfone) — nunca é nil
    let inputNode = engine.inputNode
    let inputFormat = inputNode.outputFormat(forBus: 0)

    // 5. Conectar: inputNode → eqNode → mainMixerNode
    engine.connect(inputNode, to: eqNode, format: inputFormat)
    engine.connect(eqNode, to: engine.mainMixerNode, format: inputFormat)

    // 6. Instalar tap no mainMixerNode para compressor + limiter em tempo real
    let mixerFormat = engine.mainMixerNode.outputFormat(forBus: 0)
    engine.mainMixerNode.installTap(
      onBus: 0,
      bufferSize: AudioProcessingConstants.bufferSize,
      format: mixerFormat
    ) { [weak self] buffer, _ in
      self?.processBuffer(buffer)
    }

    // 7. Iniciar engine
    do {
      try engine.start()
      isSetup = true
      print("✅ AVAudioEngineProcessor started")
    } catch {
      print("❌ AVAudioEngine start error: \(error)")
    }
  }

  /// Configura todas as bandas EQ como flat (gain = 0)
  private func setupEQFlat() {
    let frequencies: [Float] = [63, 125, 250, 500, 1000, 2000, 4000, 8000]
    for (i, freq) in frequencies.enumerated() {
      let band = eqNode.bands[i]
      band.filterType = .parametric
      band.frequency = freq
      band.bandwidth = 1.0
      band.gain = 0.0
      band.bypass = false
    }
  }
  
  // MARK: - Processing (tap callback — render thread)

  private func processBuffer(_ buffer: AVAudioPCMBuffer) {
    guard let channelData = buffer.floatChannelData else { return }
    let frames = Int(buffer.frameLength)
    let ch = channelData[0]

    // Capturar parâmetros localmente para evitar data-race
    let gain = masterGainLinear
    let limit = limiterThreshold
    let useCompressor = compressorEnabled

    // 1. Compressor DSP
    if useCompressor, let compressor = compressorDSP {
      var samples = Array(UnsafeBufferPointer(start: ch, count: frames))
      samples = compressor.process(samples)
      for i in 0..<frames { ch[i] = samples[i] }
    }

    // 2. Master gain + hard limiter (em um único passo)
    for i in 0..<frames {
      var s = ch[i] * gain
      if s > limit  { s =  limit }
      if s < -limit { s = -limit }
      ch[i] = s
    }
  }

  // MARK: - Public Methods (MethodChannel handlers)

  /// Aplica preset de EQ com lista de bandas { frequency, gain }
  @objc func applyEQPreset(preset: String, bands: [[String: NSNumber]]) {
    // Primeiro zera todas as bandas
    for band in eqNode.bands { band.gain = 0.0 }

    // Aplica cada banda recebida
    for bandData in bands {
      guard let frequency = bandData["frequency"]?.floatValue,
            let gain      = bandData["gain"]?.floatValue else { continue }
      // Encontra a banda mais próxima da frequência solicitada
      if let band = eqNode.bands.min(by: {
        abs($0.frequency - frequency) < abs($1.frequency - frequency)
      }) {
        band.gain = min(max(gain, -12), 12)
      }
    }
    print("✅ EQ '\(preset)' applied (\(bands.count) bands)")
  }

  @objc func setCompressor(
    threshold: NSNumber, ratio: NSNumber,
    attackTime: NSNumber, releaseTime: NSNumber, makeupGain: NSNumber
  ) {
    compressorDSP?.updateParameters(
      threshold: threshold.floatValue,
      ratio: ratio.floatValue,
      attackTime: attackTime.floatValue,
      releaseTime: releaseTime.floatValue,
      makeupGain: makeupGain.floatValue
    )
    print("✅ Compressor: \(threshold)dB \(ratio):1")
  }

  @objc func setMasterGain(_ gainDb: NSNumber) {
    let db = min(max(gainDb.floatValue, -12), 12)
    masterGainLinear = pow(10.0, db / 20.0)
    print("✅ Master Gain: \(db)dB → \(masterGainLinear)x")
  }

  @objc func setLimiterThreshold(_ thresholdDb: NSNumber) {
    let db = min(max(thresholdDb.floatValue, -6), 0)
    limiterThreshold = pow(10.0, db / 20.0)
    print("✅ Limiter: \(db)dB → \(limiterThreshold)x")
  }

  @objc func toggleCompressor(_ enabled: NSNumber) {
    compressorEnabled = enabled.boolValue
    if !compressorEnabled { compressorDSP?.reset() }
    print("✅ Compressor: \(compressorEnabled ? "ON" : "OFF")")
  }

  @objc func resetAudio() {
    for band in eqNode.bands { band.gain = 0.0 }
    compressorDSP?.reset()
    compressorDSP?.updateParameters(
      threshold: -12, ratio: 4, attackTime: 5, releaseTime: 50, makeupGain: 4
    )
    masterGainLinear = 1.0
    limiterThreshold = 1.0
    compressorEnabled = true
    print("✅ Audio reset to defaults")
  }

  @objc func shutdown() {
    engine.mainMixerNode.removeTap(onBus: 0)
    engine.stop()
    isSetup = false
    print("✅ AVAudioEngine stopped")
  }
}
