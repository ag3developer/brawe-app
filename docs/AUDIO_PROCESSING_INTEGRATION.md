# 🎙️ Brawe Audio Processing - Integração Nativa

**Status**: ✅ Serviço Dart criado | ⏳ Integração Nativa (iOS/Android) em Progresso

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura](#arquitetura)
3. [Presets de EQ](#presets-de-eq)
4. [Compressor](#compressor)
5. [Integração iOS (AVAudioEngine)](#integração-ios-avaudioengine)
6. [Integração Android (AAudio)](#integração-android-aaudio)
7. [UI/UX](#uiux)
8. [Roadmap](#roadmap)

---

## Visão Geral

O **BroadcastAudioProcessing** é um serviço de áudio profissional para RTMP streaming que oferece:

- **Presets de EQ** (Voice Enhancement, Music Boost, Gaming, Podcast, Studio, Flat)
- **Compressor dinâmico** com controle fino (Light/Medium/Aggressive)
- **Master Gain** (±12dB)
- **Limiter** para proteção contra clipping
- **UI moderna** com visualização em tempo real

### Objetivos

✅ "Live Perfeita" — áudio profissional em tempo real  
✅ Compatibilidade iOS/Android  
✅ Integração com RTMP (rtmp_broadcaster)  
✅ Zero latência (processamento antes do encoding)  
✅ Controle total para streamers

---

## Arquitetura

```
┌─────────────────────────────────────┐
│  BroadcastAudioProcessing (Dart)   │ ← Controller (UI + State Management)
│  - Presets de EQ                   │
│  - Compressor Config               │
│  - Master Gain                      │
│  - Limiter                         │
└────────┬────────────────────────────┘
         │ Method Channel
         ├─────────────────────────────────┬───────────────────────────┐
         │                                 │                           │
    ┌────▼──────────┐            ┌────────▼──────┐        ┌──────────▼───┐
    │  iOS Native   │            │ Android Native │        │ Future: Web  │
    │  (Swift)      │            │ (Kotlin)       │        │              │
    │               │            │                │        │              │
    │ AVAudioEngine │            │ AAudio / Web   │        │ WebAudio API │
    │ + EQ nodes    │            │ + DSP chains   │        │              │
    │ + Compressor  │            │ + Compression  │        │              │
    └───────────────┘            └────────────────┘        └──────────────┘
         │                                 │
         └─────────────────────────────────┴──────────────┐
                                                          │
                                          ┌───────────────▼──────────┐
                                          │ Audio Input (PCM Stream) │
                                          │ from Microphone           │
                                          └──────────────────────────┘
                                                        │
                                                 ┌──────▼─────┐
                                                 │ RTMP       │
                                                 │ Broadcaster│
                                                 │ (encoded)  │
                                                 └────────────┘
```

---

## Presets de EQ

Cada preset é definido em **bandas de frequência** com ganho (dB) e Q-factor:

### 1. **Voice Enhancement** (🎙️ Default)
```
Ideal: Podcasts, entrevistas, streamers conversadores
100Hz → -2dB (reduz rumble)
500Hz → +1dB (warmth)
2kHz → +4dB (presença)
4kHz → +3dB (claridade)
8kHz → -1dB (suaviza sibilantes)
```

### 2. **Music Boost** (🎵)
```
Ideal: Streamers de música, DJ, ambientes musicais
60Hz → +4dB (bass boost)
250Hz → +2dB (bass warmth)
1kHz → -1dB (reduz muddiness)
4kHz → +2dB (treble presence)
10kHz → +3dB (treble sparkle)
```

### 3. **Gaming** (🎮)
```
Ideal: Streamers de games — realça diálogos + efeitos
500Hz → +2dB (mids presence)
2kHz → +3dB (dialogue clarity)
4kHz → +2dB (effect details)
8kHz → +1dB (treble)
```

### 4. **Podcast** (🎧)
```
Ideal: Podcasters, educadores, conversadores
80Hz → -2dB (reduz rumble)
300Hz → +2dB (warmth)
3kHz → +3dB (presence)
7kHz → -2dB (sibilant control)
12kHz → -1dB (smooth highs)
```

### 5. **Studio** (✨)
```
Ideal: Perfeccionistas, produtores
50Hz → -1dB (subsonic roll-off)
10kHz → -0.5dB (gentle air control)
(Tudo mais é flat)
```

### 6. **Flat** (⚪)
```
Sem processamento — baseline para testes/comparações
```

---

## Compressor

### Função

Reduz a dinâmica do áudio — evita que picos altos clippem e baixos desapareçam.

### Presets

| Preset | Threshold | Ratio | Attack | Release | Makeup Gain | Uso |
|--------|-----------|-------|--------|---------|-------------|-----|
| **Light** | -18dB | 2:1 | 10ms | 100ms | +2dB | Transparente, para conteúdo já bem balanceado |
| **Medium** | -12dB | 4:1 | 5ms | 50ms | +4dB | Versátil, balanceado, recomendado |
| **Aggressive** | -6dB | 8:1 | 1ms | 20ms | +6dB | Controle forte, para conteúdo muito dinâmico |

### Explicação

```
Threshold (-18dB): Onde o compressor começa a atuar
Ratio (2:1): Para cada 2dB acima do threshold, sai 1dB
Attack (10ms): Velocidade de ativação
Release (100ms): Velocidade de desativação
Makeup Gain (+2dB): Compensa a redução de volume
```

---

## Integração iOS (AVAudioEngine)

### Arquivo: `/ios/BraweAudio/AVAudioEngineProcessor.swift`

```swift
import AVFoundation

class AVAudioEngineProcessor {
    let engine = AVAudioEngine()
    let mixer = AVAudioMixerNode()
    
    // EQ
    let eqNode = AVAudioUnitEQ()
    
    // Compressor
    let compressorNode = AVAudioUnitEffect()
    
    // Limiter
    let limiterNode = AVAudioUnitEffect()
    
    func setupAudioProcessing() {
        // 1. Criar chain: Input → EQ → Compressor → Limiter → Output
        engine.attach(mixer)
        engine.attach(eqNode)
        engine.attach(compressorNode)
        engine.attach(limiterNode)
        
        // 2. Conectar nós
        let inputNode = engine.inputNode
        engine.connect(inputNode, to: eqNode, format: nil)
        engine.connect(eqNode, to: compressorNode, format: nil)
        engine.connect(compressorNode, to: limiterNode, format: nil)
        engine.connect(limiterNode, to: mixer, format: nil)
        engine.connect(mixer, to: engine.mainMixerNode, format: nil)
        
        // 3. Iniciar engine
        do {
            try engine.start()
        } catch {
            print("Falha ao iniciar AVAudioEngine: \(error)")
        }
    }
    
    func applyEQPreset(_ preset: String, bands: [[String: Double]]) {
        // Exemplo: bands = [
        //   {"frequency": 100, "gain": -2, "q": 1.0},
        //   {"frequency": 500, "gain": +1, "q": 1.0},
        //   ...
        // ]
        
        eqNode.bands.forEach { band in
            let eqBand = bands.first { $0["frequency"] == Double(band.frequency) }
            if let eqBand = eqBand {
                band.gain = Float(eqBand["gain"] ?? 0)
                band.bypassBandPassFilter = false
            }
        }
    }
    
    func applyCompressor(threshold: Float, ratio: Float, attackTime: Float, releaseTime: Float, makeupGain: Float) {
        // Usar AVAudioUnitEffect com preset de compressor
        // OU implementar compressor customizado via RemoteIO
        // (Mais detalhes na seção "Native Implementation")
    }
}
```

### Passos de Implementação

1. **Criar arquivo Swift** em `/ios/BraweAudio/`
2. **Registrar Method Channel** no plugin Dart
3. **Expor funções** (`applyEQ`, `setCompressor`, `setMasterGain`, `setLimiter`)
4. **Ligar com BroadcastAudioProcessing.dart** via platform channels

---

## Integração Android (AAudio)

### Arquivo: `/android/app/src/main/kotlin/com/brawe/AudioProcessor.kt`

```kotlin
package com.brawe.audio

import android.media.AudioManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.AudioTrack

class AudioProcessor {
    private var audioRecord: AudioRecord? = null
    private var audioTrack: AudioTrack? = null
    
    // EQ via Equalizer from android.media.audiofx
    private var equalizer: android.media.audiofx.Equalizer? = null
    
    // Compressor (manual DSP)
    private var compressorThreshold = -12f
    private var compressorRatio = 4f
    
    fun setupAudioProcessing() {
        // 1. Inicializar AudioRecord (input)
        val sampleRate = 44100
        val audioFormat = AudioFormat.ENCODING_PCM_16BIT
        val channelConfig = AudioFormat.CHANNEL_IN_MONO
        
        val bufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioFormat)
        audioRecord = AudioRecord(
            AudioManager.RECORDER_SOURCE_MIC,
            sampleRate,
            channelConfig,
            audioFormat,
            bufferSize
        )
        
        // 2. Inicializar Equalizer (para EQ linear)
        // Note: A standard Equalizer nativa do Android é limitada
        // Para processamento profissional, usar Web Audio ou custom DSP
    }
    
    fun applyCompressor(samples: ShortArray) {
        // DSP simples de compressor
        for (i in samples.indices) {
            val sample = samples[i].toFloat() / 32768f // Normalizar para [-1, 1]
            
            // Detector de nível
            if (sample > compressorThreshold) {
                // Aplicar compressão: (sample - threshold) / ratio + threshold
                val compressed = ((sample - compressorThreshold) / compressorRatio) + compressorThreshold
                samples[i] = (compressed * 32768f).toShort()
            }
        }
    }
}
```

### Passos de Implementação

1. **Criar classe Kotlin** em `/android/app/src/main/kotlin/`
2. **Registrar MethodChannel** na MainActivity
3. **Processar áudio capturado** antes de enviar para RTMP
4. **Integrar com rtmp_broadcaster**

---

## UI/UX

### Audio Processor Panel

Localizado em: `lib/ui/broadcaster/widgets/audio_processor_panel.dart`

#### Features

- ✅ **Grid de Presets** (6 opções com visual feedback)
- ✅ **Compressor Toggle** (on/off com presets Light/Medium/Aggressive)
- ✅ **Master Gain Slider** (±12dB com marcadores)
- ✅ **Limiter Slider** (-6dB a 0dB, proteção contra clipping)
- ✅ **Status Card** com configuração atual
- ✅ **Reset Button** para restaurar defaults

#### Integração no Broadcaster Screen

```dart
// No More Menu
MoreOptionTile(
  icon: Icons.graphic_eq_rounded,
  iconColor: Colors.pink.shade300,
  title: '🎛️ Audio Processor',
  subtitle: 'EQ profissional + Compressor — ${BroadcastAudioProcessing.currentPreset.name}',
  onTap: () {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bCtx) => AudioProcessorPanel(
        onClose: () => Navigator.pop(bCtx),
      ),
    );
  },
),
```

---

## Roadmap

### ✅ Fase 1: Core Dart (Completo)
- [x] Serviço BroadcastAudioProcessing
- [x] Presets de EQ profissionais
- [x] Compressor com 3 presets
- [x] UI (AudioProcessorPanel)
- [x] Integração no BroadcasterScreen

### ⏳ Fase 2: Native iOS (Próximo)
- [ ] AVAudioEngineProcessor em Swift
- [ ] Method Channel setup
- [ ] EQ nativo com AVAudioUnitEQ
- [ ] Compressor nativo
- [ ] Limiter nativo
- [ ] Testes em device real
- [ ] Otimização de latência

### ⏳ Fase 3: Native Android (Depois)
- [ ] AudioProcessor em Kotlin
- [ ] Integração com AudioRecord/AudioTrack
- [ ] DSP de compressor customizado
- [ ] EQ via Web Audio (fallback)
- [ ] Testes em device real

### ⏳ Fase 4: Avançado (Future)
- [ ] Espectro em tempo real (waveform no UI)
- [ ] Presets customizados salvos do usuário
- [ ] Recording de settings por streamer
- [ ] Analytics (áudio levels, clipping events)
- [ ] Integration com Discord RTC para streaming
- [ ] Support para Bluetooth mics

---

## Estrutura de Arquivos

```
brawe-app/
├── lib/
│   ├── core/services/
│   │   ├── broadcast_audio_session.dart      (✅ Existing: AVAudioSession config)
│   │   └── broadcast_audio_processing.dart   (✅ NEW: EQ + Compressor)
│   └── ui/broadcaster/widgets/
│       ├── broadcaster_screen.dart            (✅ Modified: Added UI trigger)
│       └── audio_processor_panel.dart         (✅ NEW: UI Panel)
├── docs/
│   └── AUDIO_PROCESSING_INTEGRATION.md        (this file)
└── ios/
    └── BraweAudio/                            (⏳ To be created)
        └── AVAudioEngineProcessor.swift
```

---

## Próximos Passos

### 1. iOS Implementation
```bash
# Criar arquivo Swift
touch ios/BraweAudio/AVAudioEngineProcessor.swift

# Registrar Method Channel na MainActivity.swift
# Expor functions: applyEQ, setCompressor, etc.
```

### 2. Android Implementation
```bash
# Criar arquivo Kotlin
mkdir -p android/app/src/main/kotlin/com/brawe/audio
touch android/app/src/main/kotlin/com/brawe/audio/AudioProcessor.kt
```

### 3. Teste & Validação
```bash
flutter run --release

# Testar cada preset
# Verificar latência (target: <10ms)
# Comparar com presets profissionais (Streamlabs, OBS)
```

---

## Referências

- [AVAudioEngine Documentation](https://developer.apple.com/documentation/avfoundation/avaudioengine)
- [AAudio Documentation](https://developer.android.com/ndk/guides/audio/aaudio)
- [WebAudio API (Future)](https://www.w3.org/TR/webaudio/)
- [Compressor Theory](https://en.wikipedia.org/wiki/Dynamic_range_compression)
- [EQ Presets (Industry Standards)](https://www.izotope.com/en/learn/audio-eq-presets-101/)

---

**Criado em**: 2026-05-29  
**Última atualização**: 2026-05-29  
**Status**: 🟢 Pronto para Fase 2 (iOS Native)
