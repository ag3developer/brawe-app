import Flutter
import UIKit
import AVFoundation
import Accelerate
import CoreMotion
import HaishinKit
import os
import ReplayKit
import VideoToolbox

@objc
public class FlutterRTMPStreaming : NSObject {
    private var rtmpConnection = RTMPConnection()
    private var rtmpStream: RTMPStream!
    private var url: String? = nil
    private var name: String? = nil
    private var retries: Int = 0
    private let eventSink: FlutterEventSink
    private let myDelegate = MyRTMPStreamQoSDelagate()
    
    @objc
    public init(sink: @escaping FlutterEventSink) {
        eventSink = sink
    }
    
    @objc
    public func open(url: String, width: Int, height: Int, bitrate: Int) {
        rtmpStream = RTMPStream(connection: rtmpConnection)
        // ✅ FIX: sessionPreset dinâmico baseado na resolução solicitada
        // Antes estava hardcoded em hd1280x720 (720p) mesmo pedindo 1080p
        let sessionPreset: AVCaptureSession.Preset
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
        ]
        rtmpConnection.addEventListener(.rtmpStatus, selector:#selector(rtmpStatusHandler), observer: self)
        rtmpConnection.addEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
        
        let uri = URL(string: url)
        self.name = uri?.pathComponents.last
        var bits = url.components(separatedBy: "/")
        bits.removeLast()
        self.url = bits.joined(separator: "/")
        
        // ✅ FIX: H264 High profile em vez de Baseline
        // High = melhor compressão → mesma qualidade com menos bits (ou mais nítido com mesmo bitrate)
        // Baseline era usado por compatibilidade antiga (Flash/RTMP <2010), Mux suporta High perfeitamente
        rtmpStream.videoSettings = [
            .width: width,
            .height: height,
            .profileLevel: kVTProfileLevel_H264_High_AutoLevel,
            .maxKeyFrameIntervalDuration: 2,
            .bitrate: bitrate
        ]
        // ✅ FIX: FPS explícito junto com os video settings
        rtmpStream.captureSettings = [
            .sessionPreset: sessionPreset,
            .fps: 30,
            .continuousAutofocus: true,
            .continuousExposure: true
        ]
        rtmpStream.delegate = myDelegate
        self.retries = 0
        // Run this on the ui thread.
        DispatchQueue.main.async {
            if let orientation = DeviceUtil.videoOrientation(by:  UIApplication.shared.statusBarOrientation) {
                self.rtmpStream.orientation = orientation
                print(String(format:"Orient %d", orientation.rawValue))
                switch (orientation) {
                case .landscapeLeft, .landscapeRight:
                    self.rtmpStream.videoSettings[.width] = width;
                    self.rtmpStream.videoSettings[.height] = height;
                    break;
                default:
                    break;
                }
            }
            self.rtmpConnection.connect(self.url ?? "frog")
        }
    }
    
    @objc
    private func rtmpStatusHandler(_ notification: Notification) {
        let e = Event.from(notification)
        guard let data: ASObject = e.data as? ASObject, let code: String = data["code"] as? String else {
            return
        }
        print(e)
        
        switch code {
        case RTMPConnection.Code.connectSuccess.rawValue:
            rtmpStream.publish(name)
            retries = 0
            break
        case RTMPConnection.Code.connectFailed.rawValue, RTMPConnection.Code.connectClosed.rawValue:
            guard retries <= 3 else {
                eventSink(["event" : "error",
                           "errorDescription" : "connection failed " + e.type.rawValue])
                return
            }
            retries += 1
            Thread.sleep(forTimeInterval: pow(2.0, Double(retries)))
            rtmpConnection.connect(url!)
            eventSink(["event" : "rtmp_retry",
                       "errorDescription" : "connection failed " + e.type.rawValue])
            break
        default:
            break
        }
    }
    
    @objc
    private func rtmpErrorHandler(_ notification: Notification) {
        if #available(iOS 10.0, *) {
            os_log("%s", notification.name.rawValue)
        }
        guard retries <= 3 else {
            eventSink(["event" : "rtmp_stopped",
                       "errorDescription" : "rtmp disconnected"])
            return
        }
        retries+=1
        Thread.sleep(forTimeInterval: pow(2.0, Double(retries)))
        rtmpConnection.connect(url!)
        eventSink(["event" : "rtmp_retry",
                   "errorDescription" : "rtmp disconnected"])
        
    }
    
    @objc
    public func pauseVideoStreaming() {
        rtmpStream.paused = true
    }
    
    @objc
    public func resumeVideoStreaming() {
        rtmpStream.paused = false
    }
    
    @objc
    public func isPaused() -> Bool{
        return rtmpStream.paused
    }
    
    
    @objc
    public func getStreamStatistics() -> NSDictionary {
        let ret: NSDictionary = [
            "paused": isPaused(),
            "bitrate": rtmpStream.videoSettings[.bitrate]!,
            "width": rtmpStream.videoSettings[.width]!,
            "height": rtmpStream.videoSettings[.height]!,
            "fps": (rtmpStream.captureSettings[.fps]! as! NSNumber).floatValue,
            "orientation": rtmpStream.orientation.rawValue
        ]
        //ret["cacheSize"] = rtmpConnection.bandWidth
        //ret["sentAudioFrames"] = rtmpCamera!!.sentAudioFrames
        //        ret["sentVideoFrames"] = rtmpCamera!!.sentVideoFrames
        //if (rtmpCamera!!.droppedAudioFrames == null) {
        //ret["droppedAudioFrames"] = 0
        //} else {
        //ret["droppedAudioFrames"] = rtmpCamera!!.droppedAudioFrames
        //}
        //ret["droppedVideoFrames"] = rtmpCamera!!.droppedVideoFrames
        //ret["isAudioMuted"] = rtmpCamera!!.isAudioMuted
        return ret
    }
    
    @objc
    public func addVideoData(buffer: CMSampleBuffer) {
        if let description = CMSampleBufferGetFormatDescription(buffer) {
            let dimensions = CMVideoFormatDescriptionGetDimensions(description)
            // ✅ FIX: High profile + bitrate proporcional à resolução + 30fps
            // Antes: Baseline + 1.2Mbps fixo + 24fps → imagem embacada
            let isHD = dimensions.width >= 1920 || dimensions.height >= 1920
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
            ]
        }
        rtmpStream.appendSampleBuffer( buffer, withType: .video)
    }
    
    @objc
    public func addAudioData(buffer: CMSampleBuffer) {
        // ✅ Processa EQ + Compressor + Gain antes do encoding RTMP
        // Usa NSClassFromString para evitar dependência de compilação no pub-cache
        if let processorClass = NSClassFromString("Runner.AVAudioEngineProcessor") as? NSObject.Type,
           let shared = processorClass.value(forKey: "shared") as? NSObject,
           shared.responds(to: NSSelectorFromString("processCMSampleBuffer:")) {
            shared.perform(NSSelectorFromString("processCMSampleBuffer:"), with: buffer)
        }
        rtmpStream.appendSampleBuffer( buffer, withType: .audio)
    }
    
    @objc
    public func close() {
        rtmpConnection.close()
    }
}


class MyRTMPStreamQoSDelagate: RTMPStreamDelegate {
    // ✅ FIX: limites de adaptive bitrate ajustados para 1080p
    // Antes: maxBitrate = 2.5Mbps (insuficiente para 1080p HD)
    // Agora: maxBitrate = 6Mbps (ideal para 1080p), min = 500Kbps
    let minBitrate: UInt32 = 500 * 1024
    let maxBitrate: UInt32 = 6000 * 1024
    let incrementBitrate: UInt32 = 512 * 1024
    
    func didPublishSufficientBW(_ stream: RTMPStream, withConnection: RTMPConnection) {
        guard let videoBitrate = stream.videoSettings[.bitrate] as? UInt32 else { return }
        
        var newVideoBitrate = videoBitrate + incrementBitrate
        if newVideoBitrate > maxBitrate {
            newVideoBitrate = maxBitrate
        }
        print("didPublishSufficientBW update: \(videoBitrate) -> \(newVideoBitrate)")
        stream.videoSettings[.bitrate] = newVideoBitrate
    }
    
    
    // detect upload insufficent BandWidth
    func didPublishInsufficientBW(_ stream:RTMPStream, withConnection:RTMPConnection) {
        guard let videoBitrate = stream.videoSettings[.bitrate] as? UInt32 else { return }
        
        var         newVideoBitrate = UInt32(videoBitrate / 2)
        if newVideoBitrate < minBitrate {
            newVideoBitrate = minBitrate
        }
        print("didPublishInsufficientBW update: \(videoBitrate) -> \(newVideoBitrate)")
        stream.videoSettings[.bitrate] = newVideoBitrate
    }
    
    func clear() {
    }
}
