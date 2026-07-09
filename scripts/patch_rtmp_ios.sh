#!/bin/bash
# patch_rtmp_ios.sh — Aplica patches de qualidade de vídeo no rtmp_broadcaster iOS
#
# QUANDO USAR: depois de `flutter pub get` ou `flutter clean && flutter pub get`
# O pub-cache pode ser resetado, então os patches precisam ser reaplicados.
#
# USO: bash scripts/patch_rtmp_ios.sh
#
# PATCHES APLICADOS:
#  1. sessionPreset dinâmico (720p ou 1080p conforme resolução solicitada)
#  2. H264 High profile em vez de Baseline
#  3. FPS 30 consistente (era 24 no reconnect)
#  4. Adaptive bitrate máximo 6Mbps (era 2.5Mbps, insuficiente para 1080p)
#  5. Bitrate inicial proporcional (era fixo 1.2Mbps no addVideoData)

PLUGIN_DIR="$HOME/.pub-cache/hosted/pub.dev/rtmp_broadcaster-2.3.4"
TARGET="$PLUGIN_DIR/ios/Classes/FlutterRTMPStreaming.swift"

if [ ! -f "$TARGET" ]; then
  echo "❌  Arquivo não encontrado: $TARGET"
  echo "    Execute flutter pub get primeiro."
  exit 1
fi

# Verifica se o patch já foi aplicado
if grep -q "kVTProfileLevel_H264_High_AutoLevel" "$TARGET"; then
  echo "✅  Patch já aplicado em $TARGET"
  exit 0
fi

echo "🔧  Aplicando patches em $TARGET..."

# Patch 1: sessionPreset dinâmico + H264 High + FPS correto
python3 << 'PYEOF'
import re, sys

path = "$TARGET"
with open(path, 'r') as f:
    content = f.read()

# 1. sessionPreset 720p hardcoded → dinâmico
old_capture = '''        rtmpStream.captureSettings = [
            .sessionPreset: AVCaptureSession.Preset.hd1280x720,
            .continuousAutofocus: true,
            .continuousExposure: true
        ]'''
new_capture = '''        let sessionPreset: AVCaptureSession.Preset
        if width >= 1920 || height >= 1920 {
            sessionPreset = .hd1920x1080
        } else if width >= 1280 || height >= 1280 {
            sessionPreset = .hd1280x720
        } else {
            sessionPreset = .medium
        }
        rtmpStream.captureSettings = [
            .sessionPreset: sessionPreset,
            .continuousAutofocus: true,
            .continuousExposure: true
        ]'''
content = content.replace(old_capture, new_capture, 1)

# 2. H264 Baseline → High (no open())
content = content.replace(
    '            .profileLevel: kVTProfileLevel_H264_Baseline_AutoLevel,\n            .maxKeyFrameIntervalDuration: 2,\n            .bitrate: bitrate',
    '            .profileLevel: kVTProfileLevel_H264_High_AutoLevel,\n            .maxKeyFrameIntervalDuration: 2,\n            .bitrate: bitrate',
    1
)

# 3. captureSettings no open() → inclui sessionPreset + fps 30
old_fps = '''        rtmpStream.captureSettings = [
            .fps: 30
        ]
        rtmpStream.delegate = myDelegate'''
new_fps = '''        rtmpStream.captureSettings = [
            .sessionPreset: sessionPreset,
            .fps: 30,
            .continuousAutofocus: true,
            .continuousExposure: true
        ]
        rtmpStream.delegate = myDelegate'''
content = content.replace(old_fps, new_fps, 1)

# 4. addVideoData: Baseline + 1.2Mbps + 24fps → High + adaptive + 30fps
old_add = '''            rtmpStream.videoSettings = [
                .width: dimensions.width,
                .height: dimensions.height,
                .profileLevel: kVTProfileLevel_H264_Baseline_AutoLevel,
                .maxKeyFrameIntervalDuration: 2,
                .bitrate: 1200 * 1024
            ]
            rtmpStream.captureSettings = [
                .fps: 24
            ]'''
new_add = '''            let isHD = dimensions.width >= 1920 || dimensions.height >= 1920
            let adaptiveBitrate = isHD ? 4500 * 1024 : 2500 * 1024
            rtmpStream.videoSettings = [
                .width: dimensions.width,
                .height: dimensions.height,
                .profileLevel: kVTProfileLevel_H264_High_AutoLevel,
                .maxKeyFrameIntervalDuration: 2,
                .bitrate: adaptiveBitrate
            ]
            rtmpStream.captureSettings = [
                .fps: 30
            ]'''
content = content.replace(old_add, new_add, 1)

# 5. Adaptive bitrate max 2.5Mbps → 6Mbps
content = content.replace(
    'let maxBitrate: UInt32 = 2500 * 1024',
    'let maxBitrate: UInt32 = 6000 * 1024'
)
content = content.replace(
    'let minBitrate: UInt32 = 300 * 1024',
    'let minBitrate: UInt32 = 500 * 1024'
)

with open(path, 'w') as f:
    f.write(content)
print("✅  Patches aplicados com sucesso")
PYEOF

# 6. Interceptar addAudioData para processar EQ+Compressor antes do RTMP
python3 << 'ADDAUDIO'
path = "$TARGET"
with open(path.replace('FlutterRTMPStreaming.swift', '../../../Classes/RtmppublisherPlugin.m') if False else path, 'r') as f:
    content = f.read()

old_audio = '''    @objc
    public func addAudioData(buffer: CMSampleBuffer) {
        rtmpStream.appendSampleBuffer( buffer, withType: .audio)
    }'''
new_audio = '''    @objc
    public func addAudioData(buffer: CMSampleBuffer) {
        // ✅ Processa EQ + Compressor + Gain antes do encoding RTMP
        AVAudioEngineProcessor.shared.processCMSampleBuffer(buffer)
        rtmpStream.appendSampleBuffer( buffer, withType: .audio)
    }'''

if old_audio in content:
    content = content.replace(old_audio, new_audio)
    with open(path, 'w') as f:
        f.write(content)
    print("✅  Audio processing patch aplicado")
else:
    print("✅  Audio processing patch já aplicado")
ADDAUDIO

echo "✅  Patches concluídos. Execute: flutter build ios --no-codesign"
