//
//  CameraModel.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

@preconcurrency import AVFoundation
import Photos
import SwiftUI
import Vision

@MainActor
@Observable
final class CameraModel: NSObject {
    private(set) var frameToDisplay: CVImageBuffer?
    private(set) var lastAnalyzedFrame: CVImageBuffer?
    private(set) var lastMatchedObservations = [RecognizedTextObservation]()
    
    private(set) var searchKeyword: String
    private(set) var recognizedTextObservations = [RecognizedTextObservation]()
    private(set) var matchedObservations = [RecognizedTextObservation]()
    
    private(set) var zoomFactor: CGFloat = 2.0
    private(set) var isTorchOn: Bool = false
    
    private var isAnalyzingFrame: Bool = false
    
    private var framesToDisplayStream: AsyncStream<CVImageBuffer>?
    private var framesToAnalyzeStream: AsyncStream<CVImageBuffer>?
    private var framesToDisplayContinuation:
    AsyncStream<CVImageBuffer>.Continuation?
    private var framesToAnalyzeContinuation:
    AsyncStream<CVImageBuffer>.Continuation?
    
    private let privacyService: PrivacyService
    private let captureService: VideoCaptureService
    private let deviceService: VideoDeviceService
    private let visionService: VisionService
    
    init(
        searchKeyword: String,
        privacyService: PrivacyService,
        captureService: VideoCaptureService,
        deviceService: VideoDeviceService,
        visionService: VisionService
    ) {
        self.searchKeyword = searchKeyword
        self.privacyService = privacyService
        self.captureService = captureService
        self.deviceService = deviceService
        self.visionService = visionService
    }
    
    func start() async {
        await privacyService.fetchCameraAuthorization()
        await deviceService.fetchVideoDevice()
        guard let videoDevice = await deviceService.videoDevice else { return }
        setupStream()
        await captureService.configureSession(
            device: videoDevice,
            delegate: self
        )
        await setDefaultZoom()
        startAnalyzeFrame()
    }
}

// MARK: - CameraModel Extension Method
extension CameraModel {
    func distributeDisplayFrames() async {
        guard let framesToDisplayStream else { return }
        for await imageBuffer in framesToDisplayStream {
            frameToDisplay = imageBuffer
        }
    }
    
    func distributeAnalyzeFrames() async {
        guard let framesToAnalyzeStream else { return }
        for await imageBuffer in framesToAnalyzeStream {
            guard isAnalyzingFrame else {
                do {
                    try await Task.sleep(for: Duration.milliseconds(500))
                } catch { return }
                continue
            }
            
            await processFrame(imageBuffer)
            
            if !matchedObservations.isEmpty && isAnalyzingFrame {
                lastAnalyzedFrame = imageBuffer
                lastMatchedObservations = matchedObservations
            }
        }
    }
    
    func zoom(to factor: CGFloat) async {
        zoomFactor = await deviceService.zoom(to: factor)
    }
    
    func toggleTorch() async {
        if isTorchOn {
            isTorchOn = await deviceService.turnOffTorch()
        } else {
            isTorchOn = await deviceService.turnOnTorch()
        }
    }
    
    func focus(at point: CGPoint) async {
        await deviceService.focus(at: point)
    }
    
    func startAnalyzeFrame() {
        isAnalyzingFrame = true
    }
    
    func stopAnalyzeFrame() {
        isAnalyzingFrame = false
    }
}

// MARK: - CameraModel Private Extension Method
private extension CameraModel {
    func processFrame(_ buffer: CVImageBuffer) async {
        do {
            let textRects = try await visionService.performTextRecognition(
                image: buffer,
                customWords: searchKeyword
            )
            
            // 분석 일시정지시 반영 중단
            guard isAnalyzingFrame else { return }
            
            self.recognizedTextObservations = textRects
            filterMatchedObservations()
        } catch {
            print("Vision Processing Error !")
        }
    }
    
    func setupStream() {
        framesToDisplayStream = AsyncStream(
            bufferingPolicy: .bufferingNewest(1)
        ) { continuation in
            self.framesToDisplayContinuation = continuation
        }
        
        framesToAnalyzeStream = AsyncStream(
            bufferingPolicy: .bufferingNewest(1)
        ) { continuation in
            self.framesToAnalyzeContinuation = continuation
        }
    }
    
    func filterMatchedObservations() {
        matchedObservations = recognizedTextObservations.filter {
            $0.transcript.localizedCaseInsensitiveContains(searchKeyword)
        }
    }
    
    func setDefaultZoom() async {
        await zoom(to: 2.0)
    }
}

// MARK: - Camera Model AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard sampleBuffer.isValid, let imageBuffer = sampleBuffer.imageBuffer
        else { return }
        Task { @MainActor in
            framesToDisplayContinuation?.yield(imageBuffer)
            if isAnalyzingFrame {
                framesToAnalyzeContinuation?.yield(imageBuffer)
            }
        }
    }
}
