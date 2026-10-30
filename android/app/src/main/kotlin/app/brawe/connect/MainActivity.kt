package app.brawe.connect

import android.graphics.Color
import android.os.Bundle
import androidx.activity.SystemBarStyle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "com.brawe/audioProcessor"
    private val processor = AudioProcessor.instance

    // Android 15 (targetSdk 35) mostra o app de ponta a ponta. Usamos o
    // caminho oficial recomendado pelo Play Console, `enableEdgeToEdge()`,
    // que também funciona nas versões antigas do Android (barras
    // transparentes; ícones claros/escuros conforme o tema do sistema).
    // `FlutterFragmentActivity` (e não `FlutterActivity`) porque a extensão
    // vem de `ComponentActivity` — e é o tipo que a biometria (local_auth)
    // também exige. Os recuos (SafeArea/MediaQuery) são tratados no Flutter.
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge(
            statusBarStyle = SystemBarStyle.auto(Color.TRANSPARENT, Color.TRANSPARENT),
            navigationBarStyle = SystemBarStyle.auto(Color.TRANSPARENT, Color.TRANSPARENT),
        )
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
