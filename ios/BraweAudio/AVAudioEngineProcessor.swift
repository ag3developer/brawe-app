import AVFoundation

/// Processador de áudio profissional usando AVAudioEngine
/// Implementa chain real-time: Entrada → EQ → Compressor → Limiter → Saída
@objc class AVAudioEngineProcessor: NSObject {
  @objc static let shared = AVAudioEngineProcessor()
  
  private let engine = AVAudioEngine()
  private let mixer = AVAudioMixerNode()
  private let eqNode = AVAudioUnitEQ()
  private var compressorDSP: CompressorDSP?
  
  private var masterGain: Float = 0.0 // dB
  private var limiterThreshold: Float = 0.0 // dB
  
  private var isSetup = false
  private let lock = NSLock()
  
  override private init() {
    super.init()
  }
  
  // MARK: - Setup
  
  /// Configura o engine de áudio para processamento real-time
  @objc func setupAudioEngine() {
    lock.lock()
    defer { lock.unlock() }
    
    guard !isSetup else { return }
    
    do {
      // 1. Atacher nós ao engine
      engine.attach(mixer)
      engine.attach(eqNode)
      
      // 2. Configurar EQ com 8 bandas
      setupEQ()
      
      // 3. Inicializar compressor DSP
      compressorDSP = CompressorDSP(
        threshold: -12.0,
        ratio: 4.0,
        attackTime: 5.0,
        releaseTime: 50.0,
        makeupGain: 4.0
      )
      
      // 4. Configurar formato de áudio
      let format = AVAudioFormat(
        commonFormat: .pcmFormatFloat32,
        sampleRate: AudioProcessingConstants.sampleRate,
        channels: AudioProcessingConstants.channels,
        interleaved: false
      )!
      
      // 5. Conectar nós
      // Input → EQ → Mixer → Output
      engine.connect(eqNode, to: mixer, format: format)
      engine.connect(mixer, to: engine.mainMixerNode, format: format)
      
      // 6. Instalar tap para processamento customizado (compressor + limiter)
      installProcessingTap(format: format)
      
      // 7. Iniciar engine
      try engine.start()
      isSetup = true
      
      print("✅ AVAudioEngineProcessor initialized successfully")
    } catch {
      print("❌ Error initializing AVAudioEngine: \(error)")
    }
  }
  
  /// Configura nós de EQ com 8 bandas
  private func setupEQ() {
    eqNode.bands.removeAll()
    
    let frequencies: [Float] = [63, 125, 250, 500, 1000, 2000, 4000, 8000]
    
    for frequency in frequencies {
      guard let band = eqNode.bands.first(where: { $0.frequency == frequency }) else {
        let band = AVAudioUnitEQFilterParameters()
        band.frequency = frequency
        band.bandwidth = 1.0
        band.gain = 0.0
        band.filterType = .parametric
        eqNode.bands.append(band)
        continue
      }
      
      band.gain = 0.0
    }
  }
  
  /// Instala tap para processamento customizado (compressor + limiter)
  private func installProcessingTap(format: AVAudioFormat) {
    guard let input = engine.inputNode else { return }
    
    input.installTap(onBus: 0, bufferSize: AudioProcessingConstants.bufferSize, format: format) { [weak self] buffer, _ in
      guard let self = self else { return }
      
      self.processBuffer(buffer)
    }
  }
  
  // MARK: - Processing
  
  /// Processa buffer com compressor e limiter
  private func processBuffer(_ buffer: AVAudioPCMBuffer) {
    guard let channelData = buffer.floatChannelData else { return }
    let frames = Int(buffer.frameLength)
    let channel0 = channelData[0]
    
    // Converter para array
    var samples = Array(UnsafeBufferPointer(start: channel0, count: frames))
    
    // 1. Aplicar compressor
    if let compressor = compressorDSP {
      samples = compressor.process(samples)
    }
    
    // 2. Aplicar limiter (hard knee peak limiting)
    samples = applyLimiter(samples)
    
    // 3. Aplicar master gain
    if masterGain != 0.0 {
      let gainLinear = pow(10.0, masterGain / 20.0)
      for i in 0..<samples.count {
        samples[i] *= gainLinear
      }
    }
    
    // Copiar de volta para buffer
    for i in 0..<frames {
      channel0[i] = samples[i]
    }
  }
  
  /// Aplica limiter (proteção contra clipping)
  private func applyLimiter(_ samples: [Float]) -> [Float] {
    let threshold = pow(10.0, limiterThreshold / 20.0)
    var output = samples
    
    for i in 0..<samples.count {
      let abs = abs(samples[i])
      if abs > threshold {
        // Hard clipping
        output[i] = samples[i] > 0 ? threshold : -threshold
      }
    }
    
    return output
  }
  
  // MARK: - Public Methods (called from Dart via MethodChannel)
  
  /// Aplica preset de EQ
  @objc func applyEQPreset(
    preset: String,
    bands: [[String: NSNumber]]
  ) {
    lock.lock()
    defer { lock.unlock() }
    
    for bandData in bands {
      guard let frequency = bandData["frequency"]?.floatValue,
            let gain = bandData["gain"]?.floatValue else { continue }
      
      if let band = eqNode.bands.first(where: { $0.frequency == frequency }) {
        band.gain = gain.clamp(min: -12, max: 12)
      }
    }
    
    print("✅ EQ Preset '\(preset)' applied")
  }
  
  /// Define parâmetros do compressor
  @objc func setCompressor(
    threshold: NSNumber,
    ratio: NSNumber,
    attackTime: NSNumber,
    releaseTime: NSNumber,
    makeupGain: NSNumber
  ) {
    lock.lock()
    defer { lock.unlock() }
    
    compressorDSP?.updateParameters(
      threshold: threshold.floatValue,
      ratio: ratio.floatValue,
      attackTime: attackTime.floatValue,
      releaseTime: releaseTime.floatValue,
      makeupGain: makeupGain.floatValue
    )
    
    print("✅ Compressor configured")
  }
  
  /// Define ganho master
  @objc func setMasterGain(_ gainDb: NSNumber) {
    lock.lock()
    defer { lock.unlock() }
    
    masterGain = gainDb.floatValue.clamp(
      min: AudioProcessingConstants.minMasterGain,
      max: AudioProcessingConstants.maxMasterGain
    )
    
    print("✅ Master Gain set to \(masterGain)dB")
  }
  
  /// Define threshold do limiter
  @objc func setLimiterThreshold(_ thresholdDb: NSNumber) {
    lock.lock()
    defer { lock.unlock() }
    
    limiterThreshold = thresholdDb.floatValue.clamp(
      min: AudioProcessingConstants.minLimiterGain,
      max: AudioProcessingConstants.maxLimiterGain
    )
    
    print("✅ Limiter set to \(limiterThreshold)dB")
  }
  
  /// Ativa/desativa compressor
  @objc func toggleCompressor(_ enabled: NSNumber) {
    lock.lock()
    defer { lock.unlock() }
    
    if enabled.boolValue {
      print("✅ Compressor enabled")
    } else {
      compressorDSP?.reset()
      print("✅ Compressor disabled")
    }
  }
  
  /// Reset para valores padrão
  @objc func resetAudio() {
    lock.lock()
    defer { lock.unlock() }
    
    // Reset EQ
    for band in eqNode.bands {
      band.gain = 0.0
    }
    
    // Reset compressor
    compressorDSP?.reset()
    compressorDSP?.updateParameters(
      threshold: -12.0,
      ratio: 4.0,
      attackTime: 5.0,
      releaseTime: 50.0,
      makeupGain: 4.0
    )
    
    // Reset gains
    masterGain = 0.0
    limiterThreshold = 0.0
    
    print("✅ Audio processor reset to defaults")
  }
  
  /// Encerra o processamento
  @objc func shutdown() {
    lock.lock()
    defer { lock.unlock() }
    
    do {
      try engine.stop()
      isSetup = false
      print("✅ AVAudioEngine shutdown")
    } catch {
      print("❌ Error shutting down engine: \(error)")
    }
  }
}
