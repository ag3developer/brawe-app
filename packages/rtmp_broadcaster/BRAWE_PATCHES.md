# Patches Brawe sobre rtmp_broadcaster 2.3.4

Cópia do pacote do pub.dev com alterações locais (antes existiam só no ~/.pub-cache e se perdiam num `pub get` limpo/CI). Diff contra o original:

```diff
--- ios/Classes/FlutterRTMPStreaming.swift	2025-02-28 16:16:03
+++ ios/Classes/FlutterRTMPStreaming.swift	2026-07-09 06:50:14
@@ -26,8 +26,18 @@
     @objc
     public func open(url: String, width: Int, height: Int, bitrate: Int) {
         rtmpStream = RTMPStream(connection: rtmpConnection)
+        // ✅ FIX: sessionPreset dinâmico baseado na resolução solicitada
+        // Antes estava hardcoded em hd1280x720 (720p) mesmo pedindo 1080p
+        let sessionPreset: AVCaptureSession.Preset
+        if width >= 1920 || height >= 1920 {
+            sessionPreset = .hd1920x1080
+        } else if width >= 1280 || height >= 1280 {
+            sessionPreset = .hd1280x720
+        } else {
+            sessionPreset = .medium
+        }
         rtmpStream.captureSettings = [
-            .sessionPreset: AVCaptureSession.Preset.hd1280x720,
+            .sessionPreset: sessionPreset,
             .continuousAutofocus: true,
             .continuousExposure: true
         ]
@@ -40,16 +50,22 @@
         bits.removeLast()
         self.url = bits.joined(separator: "/")
         
-        // TODO: Da correggere
+        // ✅ FIX: H264 High profile em vez de Baseline
+        // High = melhor compressão → mesma qualidade com menos bits (ou mais nítido com mesmo bitrate)
+        // Baseline era usado por compatibilidade antiga (Flash/RTMP <2010), Mux suporta High perfeitamente
         rtmpStream.videoSettings = [
             .width: width,
             .height: height,
-            .profileLevel: kVTProfileLevel_H264_Baseline_AutoLevel,
+            .profileLevel: kVTProfileLevel_H264_High_AutoLevel,
             .maxKeyFrameIntervalDuration: 2,
             .bitrate: bitrate
         ]
+        // ✅ FIX: FPS explícito junto com os video settings
         rtmpStream.captureSettings = [
-            .fps: 30
+            .sessionPreset: sessionPreset,
+            .fps: 30,
+            .continuousAutofocus: true,
+            .continuousExposure: true
         ]
         rtmpStream.delegate = myDelegate
         self.retries = 0
@@ -162,15 +178,19 @@
     public func addVideoData(buffer: CMSampleBuffer) {
         if let description = CMSampleBufferGetFormatDescription(buffer) {
             let dimensions = CMVideoFormatDescriptionGetDimensions(description)
+            // ✅ FIX: High profile + bitrate proporcional à resolução + 30fps
+            // Antes: Baseline + 1.2Mbps fixo + 24fps → imagem embacada
+            let isHD = dimensions.width >= 1920 || dimensions.height >= 1920
+            let adaptiveBitrate = isHD ? 4500 * 1024 : 2500 * 1024
             rtmpStream.videoSettings = [
                 .width: dimensions.width,
                 .height: dimensions.height,
-                .profileLevel: kVTProfileLevel_H264_Baseline_AutoLevel,
+                .profileLevel: kVTProfileLevel_H264_High_AutoLevel,
                 .maxKeyFrameIntervalDuration: 2,
-                .bitrate: 1200 * 1024
+                .bitrate: adaptiveBitrate
             ]
             rtmpStream.captureSettings = [
-                .fps: 24
+                .fps: 30
             ]
         }
         rtmpStream.appendSampleBuffer( buffer, withType: .video)
@@ -178,6 +198,13 @@
     
     @objc
     public func addAudioData(buffer: CMSampleBuffer) {
+        // ✅ Processa EQ + Compressor + Gain antes do encoding RTMP
+        // Usa NSClassFromString para evitar dependência de compilação no pub-cache
+        if let processorClass = NSClassFromString("Runner.AVAudioEngineProcessor") as? NSObject.Type,
+           let shared = processorClass.value(forKey: "shared") as? NSObject,
+           shared.responds(to: NSSelectorFromString("processCMSampleBuffer:")) {
+            shared.perform(NSSelectorFromString("processCMSampleBuffer:"), with: buffer)
+        }
         rtmpStream.appendSampleBuffer( buffer, withType: .audio)
     }
     
@@ -189,8 +216,11 @@
 
 
 class MyRTMPStreamQoSDelagate: RTMPStreamDelegate {
-    let minBitrate: UInt32 = 300 * 1024
-    let maxBitrate: UInt32 = 2500 * 1024
+    // ✅ FIX: limites de adaptive bitrate ajustados para 1080p
+    // Antes: maxBitrate = 2.5Mbps (insuficiente para 1080p HD)
+    // Agora: maxBitrate = 6Mbps (ideal para 1080p), min = 500Kbps
+    let minBitrate: UInt32 = 500 * 1024
+    let maxBitrate: UInt32 = 6000 * 1024
     let incrementBitrate: UInt32 = 512 * 1024
     
     func didPublishSufficientBW(_ stream: RTMPStream, withConnection: RTMPConnection) {
--- ios/Classes/RtmppublisherPlugin.m	2025-02-28 16:16:03
+++ ios/Classes/RtmppublisherPlugin.m	2026-05-24 02:50:51
@@ -288,11 +288,25 @@
 }
 
 - (void)start {
-    [_captureSession startRunning];
+    // Must run on background thread to avoid UI hang risk
+    if ([NSThread isMainThread]) {
+        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
+            [self->_captureSession startRunning];
+        });
+    } else {
+        [_captureSession startRunning];
+    }
 }
 
 - (void)stop {
-    [_captureSession stopRunning];
+    // Must run on background thread to avoid UI hang risk
+    if ([NSThread isMainThread]) {
+        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
+            [self->_captureSession stopRunning];
+        });
+    } else {
+        [_captureSession stopRunning];
+    }
 }
 
 - (void)captureToFile:(NSString *)path result:(FlutterResult)result {
@@ -1102,7 +1116,10 @@
                 @"captureWidth" : @(cam.captureSize.width),
                 @"captureHeight" : @(cam.captureSize.height),
                    });
-            [cam start];
+            // startRunning must be called on a background thread to avoid UI hangs
+            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
+                [cam start];
+            });
         }
     } else if ([@"startImageStream" isEqualToString:call.method]) {
         [_camera startImageStreamWithMessenger:_messenger];
--- android/build.gradle	2025-02-28 16:16:03
+++ android/build.gradle	2026-05-21 23:57:58
@@ -27,7 +27,7 @@
 
 android {
     namespace 'com.app.rtmp_publisher'
-    compileSdkVersion 33
+    compileSdkVersion 35
     buildToolsVersion "33.0.1"
     compileOptions {
         sourceCompatibility JavaVersion.VERSION_1_8
```
