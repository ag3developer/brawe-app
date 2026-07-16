package app.brawe.connect

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.brawe/audioProcessor"
    private val processor = AudioProcessor.instance

    // Android 15 (targetSdk 35) exibe apps de ponta a ponta (edge-to-edge)
    // por padrão. `FlutterActivity` estende `Activity` diretamente (não
    // `ComponentActivity`), então a extension `enableEdgeToEdge()` do
    // androidx.activity NÃO se aplica aqui — usamos diretamente
    // `WindowCompat.setDecorFitsSystemWindows(window, false)`, que é a
    // implementação subjacente usada por `enableEdgeToEdge()` e funciona
    // com qualquer Activity. Deve ser chamado ANTES de `super.onCreate()`
    // para que o sistema saiba, desde o primeiro frame, que o app vai
    // desenhar por baixo das barras de status/navegação — evitando o
    // "flash" de barras opacas antes do primeiro frame do Flutter. O
    // tratamento de WindowInsets (SafeArea, MediaQuery.padding/viewInsets)
    // continua sendo feito no lado Flutter. Ver ANDROID_EDGE_TO_EDGE_AUDIT.md
    // (Fase A) para detalhes.
    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "setupAudioEngine" -> {
                            processor.setupAudioEngine()
                            result.success(null)
                        }
                        "applyEQ" -> {
                            val preset = call.argument<String>("preset") ?: "flat"
                            @Suppress("UNCHECKED_CAST")
                            val bands = call.argument<List<Map<String, Double>>>("bands") ?: emptyList()
                            processor.applyEQPreset(preset, bands)
                            result.success(null)
                        }
                        "setCompressor" -> {
                            processor.setCompressor(
                                threshold  = (call.argument<Double>("threshold")  ?: -12.0).toFloat(),
                                ratio      = (call.argument<Double>("ratio")      ?: 4.0).toFloat(),
                                attackTime = (call.argument<Double>("attackTime") ?: 5.0).toFloat(),
                                releaseTime= (call.argument<Double>("releaseTime")?: 50.0).toFloat(),
                                makeupGain = (call.argument<Double>("makeupGain") ?: 4.0).toFloat(),
                            )
                            result.success(null)
                        }
                        "setMasterGain" -> {
                            val gain = (call.argument<Double>("gain") ?: 0.0).toFloat()
                            processor.setMasterGain(gain)
                            result.success(null)
                        }
                        "setLimiterThreshold" -> {
                            val threshold = (call.argument<Double>("threshold") ?: 0.0).toFloat()
                            processor.setLimiterThreshold(threshold)
                            result.success(null)
                        }
                        "toggleCompressor" -> {
                            val enabled = call.argument<Boolean>("enabled") ?: true
                            processor.toggleCompressor(enabled)
                            result.success(null)
                        }
                        "resetAudio" -> {
                            processor.reset()
                            result.success(null)
                        }
                        "shutdown" -> {
                            processor.shutdown()
                            result.success(null)
                        }
                        "setAudioSessionId" -> {
                            val sessionId = call.argument<Int>("sessionId") ?: 0
                            processor.setAudioSessionId(sessionId)
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    result.error("AUDIO_PROCESSOR_ERROR", e.message, null)
                }
            }
    }
}
