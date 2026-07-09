import Flutter
import AVFoundation

/// Classe helper para configurar o MethodChannel de áudio
class BraweAudioSetup {
  /// Configura o MethodChannel para audio processing
  static func setupAudioChannel(binaryMessenger: FlutterBinaryMessenger) {
    let audioChannel = FlutterMethodChannel(
      name: "com.brawe/audioProcessor",
      binaryMessenger: binaryMessenger
    )
    
    audioChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
    switch call.method {
    case "setupAudioEngine":
      AVAudioEngineProcessor.shared.setupAudioEngine()
      result(nil)
      
    case "applyEQ":
      guard let args = call.arguments as? [String: Any],
            let preset = args["preset"] as? String,
            let bands = args["bands"] as? [[String: NSNumber]] else {
        result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
        return
      }
      AVAudioEngineProcessor.shared.applyEQPreset(preset: preset, bands: bands)
      result(nil)
      
    case "setCompressor":
      guard let args = call.arguments as? [String: NSNumber] else {
        result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
        return
      }
      AVAudioEngineProcessor.shared.setCompressor(
        threshold: args["threshold"] ?? -12,
        ratio: args["ratio"] ?? 4,
        attackTime: args["attackTime"] ?? 5,
        releaseTime: args["releaseTime"] ?? 50,
        makeupGain: args["makeupGain"] ?? 4
      )
      result(nil)
      
    case "setMasterGain":
      guard let args = call.arguments as? [String: NSNumber],
            let gain = args["gain"] else {
        result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
        return
      }
      AVAudioEngineProcessor.shared.setMasterGain(gain)
      result(nil)
      
    case "setLimiterThreshold":
      guard let args = call.arguments as? [String: NSNumber],
            let threshold = args["threshold"] else {
        result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
        return
      }
      AVAudioEngineProcessor.shared.setLimiterThreshold(threshold)
      result(nil)
      
    case "toggleCompressor":
      guard let args = call.arguments as? [String: NSNumber],
            let enabled = args["enabled"] else {
        result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
        return
      }
      AVAudioEngineProcessor.shared.toggleCompressor(enabled)
      result(nil)
      
    case "resetAudio":
      AVAudioEngineProcessor.shared.resetAudio()
      result(nil)
      
    case "shutdown":
      AVAudioEngineProcessor.shared.shutdown()
      result(nil)
      
    default:
      result(FlutterMethodNotImplemented)
    }
    }
  }
}
