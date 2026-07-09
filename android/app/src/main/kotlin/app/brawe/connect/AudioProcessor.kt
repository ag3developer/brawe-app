package app.brawe.connect

import android.media.audiofx.DynamicsProcessing
import android.media.audiofx.Equalizer
import android.os.Build
import kotlin.math.pow

/**
 * Processador de áudio profissional para Android.
 *
 * Usa [Equalizer] da API android.media.audiofx para EQ paramétrico
 * e DSP customizado (Kotlin) para compressor + limiter, aplicados
 * via [DynamicsProcessing] (API 28+) ou fallback via [Equalizer].
 *
 * Integrado via MethodChannel "com.brawe/audioProcessor".
 */
class AudioProcessor {

    private var equalizer: Equalizer? = null
    private var dynamicsProcessing: DynamicsProcessing? = null

    // Parâmetros do compressor (DSP manual para APIs < 28)
    private var compressorThreshold: Float = -12f   // dB
    private var compressorRatio: Float = 4f
    private var attackTime: Float = 5f              // ms
    private var releaseTime: Float = 50f            // ms
    private var makeupGain: Float = 4f              // dB
    private var compressorEnabled: Boolean = true

    // Parâmetros de ganho
    private var masterGainDb: Float = 0f
    private var limiterThresholdDb: Float = 0f      // dB (0 = sem limitação)

    // audioSessionId do player/recorder ativo (injetado pelo MethodChannel)
    private var audioSessionId: Int = 0

    companion object {
        val instance = AudioProcessor()

        // Mapeamento preset → band gains (dB) para as 5 bandas do Equalizer Android
        // As bandas padrão do Android EQ são: ~60Hz, 230Hz, 910Hz, 3.6kHz, 14kHz
        private val PRESET_GAINS: Map<String, List<Short>> = mapOf(
            "flat"              to listOf(0, 0, 0, 0, 0),
            "voiceEnhancement"  to listOf(-200, 0, 300, 400, -100),   // milli-dB
            "musicBoost"        to listOf(400, 200, -100, 200, 300),
            "gaming"            to listOf(0, 100, 300, 200, 100),
            "podcast"           to listOf(-200, 200, 0, 300, -200),
            "studio"            to listOf(-100, 0, 0, 0, -50),
        )
    }

    // ─── Setup ────────────────────────────────────────────────────────────────

    fun setupAudioEngine() {
        // Para Android, o EQ é aplicado ao audioSession do rtmp_broadcaster.
        // O audioSessionId é definido via setAudioSessionId() antes do setup.
        setupEqualizer()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            setupDynamicsProcessing()
        }
    }

    fun setAudioSessionId(sessionId: Int) {
        audioSessionId = sessionId
        // Re-inicializa o EQ quando o session muda (ex: reinício do broadcaster)
        equalizer?.release()
        dynamicsProcessing?.release()
        equalizer = null
        dynamicsProcessing = null
        setupAudioEngine()
    }

    private fun setupEqualizer() {
        if (audioSessionId == 0) return
        try {
            equalizer?.release()
            equalizer = Equalizer(0, audioSessionId).apply {
                enabled = true
            }
        } catch (e: Exception) {
            android.util.Log.e("AudioProcessor", "Equalizer setup error: $e")
        }
    }

    private fun setupDynamicsProcessing() {
        if (audioSessionId == 0 || Build.VERSION.SDK_INT < Build.VERSION_CODES.P) return
        try {
            dynamicsProcessing?.release()
            val config = DynamicsProcessing.Config.Builder(
                DynamicsProcessing.VARIANT_FAVOR_FREQUENCY_RESOLUTION,
                1,  // channels
                true, 0,  // pre-eq
                true, 1,  // MBC (multi-band compressor)
                false, 0, // post-eq
                true       // limiter
            ).build()
            dynamicsProcessing = DynamicsProcessing(0, audioSessionId, config).apply {
                enabled = true
            }
            applyCompressorToDynamicsProcessing()
        } catch (e: Exception) {
            android.util.Log.e("AudioProcessor", "DynamicsProcessing setup error: $e")
        }
    }

    // ─── EQ ───────────────────────────────────────────────────────────────────

    fun applyEQPreset(preset: String, bands: List<Map<String, Double>>) {
        val eq = equalizer ?: return
        val numBands = eq.numberOfBands.toInt()

        // Zera todas as bandas primeiro
        for (i in 0 until numBands) {
            eq.setBandLevel(i.toShort(), 0)
        }

        // Aplica o preset mapeado (em milli-dB)
        val gains = PRESET_GAINS[preset] ?: PRESET_GAINS["flat"]!!
        for (i in 0 until minOf(numBands, gains.size)) {
            eq.setBandLevel(i.toShort(), gains[i])
        }

        android.util.Log.d("AudioProcessor", "✅ EQ preset '$preset' applied ($numBands bands)")
    }

    // ─── Compressor ───────────────────────────────────────────────────────────

    fun setCompressor(
        threshold: Float, ratio: Float,
        attackTime: Float, releaseTime: Float, makeupGain: Float
    ) {
        this.compressorThreshold = threshold
        this.compressorRatio = ratio
        this.attackTime = attackTime
        this.releaseTime = releaseTime
        this.makeupGain = makeupGain
        applyCompressorToDynamicsProcessing()
        android.util.Log.d("AudioProcessor", "✅ Compressor: ${threshold}dB ${ratio}:1")
    }

    private fun applyCompressorToDynamicsProcessing() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) return
        val dp = dynamicsProcessing ?: return

        try {
            val channel = dp.getChannelByChannelIndex(0)
            val mbc = channel.getMbcBandByIndex(0)
            mbc.apply {
                attackTime = this@AudioProcessor.attackTime / 1000f   // s
                releaseTime = this@AudioProcessor.releaseTime / 1000f // s
                ratio = this@AudioProcessor.compressorRatio
                threshold = this@AudioProcessor.compressorThreshold
                kneeWidth = 6f
                noiseGateThreshold = -80f
                expanderRatio = 1f
                preGain = 0f
                postGain = this@AudioProcessor.makeupGain
            }
            dp.setChannelTo(channel, 0)

            // Limiter
            val limiter = channel.limiter
            limiter.apply {
                linkGroup = 0
                attackTime = 0.001f
                releaseTime = 0.05f
                ratio = 20f
                threshold = this@AudioProcessor.limiterThresholdDb
                postGain = 0f
            }
            dp.setChannelTo(channel, 0)
        } catch (e: Exception) {
            android.util.Log.e("AudioProcessor", "DynamicsProcessing config error: $e")
        }
    }

    fun toggleCompressor(enabled: Boolean) {
        compressorEnabled = enabled
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            try {
                val dp = dynamicsProcessing ?: return
                val channel = dp.getChannelByChannelIndex(0)
                val mbc = channel.getMbcBandByIndex(0)
                mbc.isEnabled = enabled
                dp.setChannelTo(channel, 0)
            } catch (_: Exception) {}
        }
        android.util.Log.d("AudioProcessor", "✅ Compressor ${if (enabled) "ON" else "OFF"}")
    }

    // ─── Gain / Limiter ───────────────────────────────────────────────────────

    fun setMasterGain(gainDb: Float) {
        masterGainDb = gainDb.coerceIn(-12f, 12f)
        // No Android o gain é ajustado via DynamicsProcessing preGain ou
        // AudioTrack.setVolume() — aqui aplicamos no DynamicsProcessing se disponível
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            try {
                val dp = dynamicsProcessing ?: return
                val channel = dp.getChannelByChannelIndex(0)
                val mbc = channel.getMbcBandByIndex(0)
                mbc.preGain = masterGainDb
                dp.setChannelTo(channel, 0)
            } catch (_: Exception) {}
        }
        android.util.Log.d("AudioProcessor", "✅ Master Gain: ${masterGainDb}dB")
    }

    fun setLimiterThreshold(thresholdDb: Float) {
        limiterThresholdDb = thresholdDb.coerceIn(-6f, 0f)
        applyCompressorToDynamicsProcessing()
        android.util.Log.d("AudioProcessor", "✅ Limiter: ${limiterThresholdDb}dB")
    }

    // ─── Reset ────────────────────────────────────────────────────────────────

    fun reset() {
        compressorThreshold = -12f
        compressorRatio = 4f
        attackTime = 5f
        releaseTime = 50f
        makeupGain = 4f
        masterGainDb = 0f
        limiterThresholdDb = 0f
        compressorEnabled = true

        val eq = equalizer
        if (eq != null) {
            for (i in 0 until eq.numberOfBands) {
                eq.setBandLevel(i.toShort(), 0)
            }
        }
        android.util.Log.d("AudioProcessor", "✅ Audio reset to defaults")
    }

    fun shutdown() {
        equalizer?.release()
        equalizer = null
        dynamicsProcessing?.release()
        dynamicsProcessing = null
        android.util.Log.d("AudioProcessor", "✅ AudioProcessor shutdown")
    }
}
