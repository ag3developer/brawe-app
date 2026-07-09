# 🎛️ Brawe Audio Presets - Visualization & Reference

## EQ Presets Frequency Response

### 1. 🎤 Voice Enhancement (DEFAULT)
```
Gain (dB)
   +4 │                    
   +3 │        ╱╲         
   +2 │       ╱  ╲        
   +1 │      ╱    ╲╱╲     
    0 │─────╱──────────╲───────
   -1 │            
   -2 │╲                      ╱
      └──┴──┴──┴──┴──┴──┴──┴─┴──
       20Hz 100  500  2k   4k  8k  16k

Target Users: Podcasters, Entrevistas, Streamers Conversadores
Effect: Realça voz clara + presença + suaviza sibilantes
Best For: Voice-heavy content
```

**Bands:**
| Frequency | Gain | Q | Effect |
|-----------|------|---|--------|
| 100 Hz | -2dB | 1.0 | Reduz rumble (60Hz hum) |
| 500 Hz | +1dB | 1.0 | Warmth |
| 2000 Hz | +4dB | 1.5 | **Presença (MAIN)** |
| 4000 Hz | +3dB | 1.0 | Claridade |
| 8000 Hz | -1dB | 1.0 | Suaviza sibilantes (S's) |

---

### 2. 🎵 Music Boost
```
Gain (dB)
   +4 │ ╱╲                       
   +3 │ │ ╲                   ╱╲
   +2 │ │  ╲               ╱╱  ╲
   +1 │ │   ╲             │     ╲
    0 │─┤────╲───────────╱──────╲─────
   -1 │      ╲         ╱          ╲   
      └──┴──┴──┴──┴──┴──┴──┴──┴──┴──
       20  60  250 1k  4k  10k 16k

Target Users: Streamers de Música, DJ, Ambientes Musicais
Effect: Bass boost + treble sparkle, reduz muddiness
Best For: Musical content
```

**Bands:**
| Frequency | Gain | Q | Effect |
|-----------|------|---|--------|
| 60 Hz | +4dB | 1.0 | **Bass Boost (MAIN)** |
| 250 Hz | +2dB | 1.0 | Bass Warmth |
| 1000 Hz | -1dB | 1.0 | Reduz muddiness |
| 4000 Hz | +2dB | 1.0 | Treble Presence |
| 10000 Hz | +3dB | 1.0 | **Treble Sparkle** |

---

### 3. 🎮 Gaming
```
Gain (dB)
   +3 │         ╱╲   ╱╲     
   +2 │        ╱  ╲ ╱  ╲    
   +1 │       ╱    │    ╲   
    0 │──────╱─────╱──────╲───
   -1 │            
      └──┴──┴──┴──┴──┴──┴──┴──
       20  100 500 2k  4k  8k  16k

Target Users: Streamers de Videogames
Effect: Realça diálogos + efeitos sonoros
Best For: Game audio (dialogue + effects clarity)
```

**Bands:**
| Frequency | Gain | Q | Effect |
|-----------|------|---|--------|
| 500 Hz | +2dB | 1.0 | Mids Presence |
| 2000 Hz | +3dB | 1.5 | **Dialogue Clarity** |
| 4000 Hz | +2dB | 1.0 | Effect Details |
| 8000 Hz | +1dB | 1.0 | Treble |

---

### 4. 🎧 Podcast
```
Gain (dB)
   +3 │       ╱╲              
   +2 │      ╱  ╲             
   +1 │     ╱    ╲            
    0 │────╱──────╲───────────
   -1 │         
   -2 │─────────────╲─────────╱
      └──┴──┴──┴──┴──┴──┴──┴──┴──
       20  80  300 1k  3k  7k  12k

Target Users: Podcasters, Educadores, Streamers Conversadores
Effect: Voz profissional + reduz sibilantes
Best For: Podcast / Educational content
```

**Bands:**
| Frequency | Gain | Q | Effect |
|-----------|------|---|--------|
| 80 Hz | -2dB | 1.0 | Reduz rumble |
| 300 Hz | +2dB | 1.0 | Warmth |
| 3000 Hz | +3dB | 1.5 | **Presence (MAIN)** |
| 7000 Hz | -2dB | 1.0 | Sibilant Control |
| 12000 Hz | -1dB | 1.0 | Smooth Highs |

---

### 5. ✨ Studio
```
Gain (dB)
    0 │─────────────────────────
   -1 │╲                        ╱
      └──┴──┴──┴──┴──┴──┴──┴──┴──
       20  50 100 1k  10k 16k

Target Users: Produtores, Perfeccionistas, Streamers Pro
Effect: Minimalista - apenas essencial
Best For: Control freaks, professional audio engineers
```

**Bands:**
| Frequency | Gain | Q | Effect |
|-----------|------|---|--------|
| 50 Hz | -1dB | 1.0 | Subsonic Roll-off |
| 10000 Hz | -0.5dB | 1.0 | Gentle Air Control |

---

### 6. ⚪ Flat
```
Gain (dB)
    0 │───────────────────────────
      └──┴──┴──┴──┴──┴──┴──┴──┴──
       20  100 1k  10k 16k

Target Users: Testing, A/B Comparisons
Effect: None - Pure baseline
Best For: Reference, before/after testing
```

---

## Compressor Presets

### Attack & Release Visualization

```
TIME DOMAIN: How fast compressor reacts
────────────────────────────────────────

LIGHT (Transparent)
Signal: ▁▂▃▄▅██████▅▄▃▂▁▁▁▂▃▄▅██████▅▄▃▂▁
Out:    ▁▂▃▄▅▆▆▆▆▆▆▆▇▆▅▄▃▂▁▁▁▂▃▄▅▆▆▆▆▆▆▆▇▆▅▄▃▂▁
        Attack: 10ms, Release: 100ms (smooth)

MEDIUM (Balanced) ⭐ RECOMMENDED
Signal: ▁▂▃▄▅██████▅▄▃▂▁▁▁▂▃▄▅██████▅▄▃▂▁
Out:    ▁▂▃▄▅▆▆▆▆▆▆▇▆▆▆▇▆▇▆▆▆▆▆▆▆▆▆▆▆▆▆▆▇▆
        Attack: 5ms, Release: 50ms (balanced)

AGGRESSIVE (Control)
Signal: ▁▂▃▄▅██████▅▄▃▂▁▁▁▂▃▄▅██████▅▄▃▂▁
Out:    ▁▂▃▄▅▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▆▇
        Attack: 1ms, Release: 20ms (punchy)
```

### Compression Ratio Explanation

```
RATIO: Input dynamic range → Output dynamic range

2:1 (Light)
Input:  0dB → 20dB peak (+20dB dynamic)
Output: 0dB → 10dB peak (+10dB dynamic) ← HALF the range

4:1 (Medium) ⭐
Input:  0dB → 20dB peak (+20dB dynamic)
Output: 0dB → 5dB peak (+5dB dynamic) ← QUARTER the range

8:1 (Aggressive)
Input:  0dB → 20dB peak (+20dB dynamic)
Output: 0dB → 2.5dB peak (+2.5dB dynamic) ← Almost limiting
```

---

## Master Gain & Limiter Reference

### Master Gain (±12dB)
```
-12dB  ← Very quiet (recording preparation)
 -6dB  ← Quiet (reduce for clipping risk)
 -3dB  ← Slight reduction (safe margin)
  0dB  ← Neutral (no change)
 +3dB  ← Slight boost (more presence)
 +6dB  ← Louder (risk of clipping)
+12dB  ← Very loud (emergency only - high distortion risk)

RECOMMENDATION: Keep between -3dB and +3dB for clean audio
```

### Limiter (Ceiling)
```
Hard Limiter (Hard Knee)
│
│     Input: ████████████████████
│            ▁▂▃▄▅▆▆▆▆▆▆▆▆▆▆▆▆▆▆
│ Output ────┴──────────┘ (clipped at threshold)
│
├─0dB ← Threshold (max output allowed)
├─-3dB ← Safe (commercial broadcast standard)
├─-6dB ← Aggressive protection (loses some peaks)
│
└─ Time ──→

RECOMMENDATION: -3dB for professional streaming
```

---

## Preset Selection Guide

### By Content Type

| Content | Best Preset | Compressor | Gain |
|---------|------------|-----------|------|
| **Podcast/Talking** | Voice Enhancement or Podcast | Medium | 0-3dB |
| **Gaming** | Gaming | Medium | -3 to 0dB |
| **Music Stream** | Music Boost | Light | 0-6dB |
| **DJ Stream** | Music Boost | Light | 3-6dB |
| **ASMR** | Studio or Flat | Light | 0dB |
| **Singing** | Podcast | Medium | -3-0dB |
| **Professional** | Studio | Medium | 0dB |
| **Testing** | Flat | Off | 0dB |

### By Environment

| Scenario | Preset | Reason |
|----------|--------|--------|
| Quiet Room | Voice Enhancement | Clarity |
| Noisy Café | Podcast + Aggressive Compressor | Reduces dynamic range |
| Music Playing | Music Boost | Complements content |
| Mixed Audio | Gaming | Balanced for all frequencies |
| Perfect Conditions | Studio | Minimal processing |

---

## Audio Quality Checklist

After selecting a preset:

- [ ] **No Clipping**: Watch the limiter indicator
- [ ] **Clarity**: Voice is clear and present (not muddy)
- [ ] **Naturalness**: Doesn't sound over-processed
- [ ] **Consistency**: Levels stay relatively stable
- [ ] **Headroom**: Peak at -3dB or less (not hitting 0dB)
- [ ] **Presence**: Feels "present" without being harsh

---

## Advanced Tips

### Voice Enhancement + Medium Compressor + -3dB Master Gain
**Best for**: Podcasters who want professional radio sound
- Clarity + presence
- Controlled dynamics
- Safe headroom

### Music Boost + Light Compressor + +3dB Master Gain  
**Best for**: Music streamers
- Punchy bass + sparkling treble
- Transparent compression
- Energetic feel

### Gaming + Medium Compressor + 0dB Master Gain
**Best for**: Game streamers
- Game dialogue clear
- Effects punchy
- Consistent levels

---

**Created**: 2026-05-29  
**Reference Version**: Audio Processor Phase 1  
**Status**: 📊 Ready for Native Phase (Phase 2)
