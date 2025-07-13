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

    private(set) var recognizedTextObservations = [RecognizedTextObservation]()
    
    private(set) var zoomFactor: CGFloat = 2.0
    private(set) var isTorchOn: Bool = false
    
    private var framesToDisplayStream: AsyncStream<CVImageBuffer>?
    private var framesToAnalyzeStream: AsyncStream<CVImageBuffer>?
    private var framesToDisplayContinuation:
        AsyncStream<CVImageBuffer>.Continuation?
    private var framesToAnalyzeContinuation:
        AsyncStream<CVImageBuffer>.Continuation?

    private let privacyService = PrivacyService()
    private let captureService = VideoCaptureService()
    private let deviceService = VideoDeviceService()
    private let visionService = VisionService()

    func start() async {
        await privacyService.fetchCameraAuthorization()
        await deviceService.fetchVideoDevice()
        guard let videoDevice = await deviceService.videoDevice else { return }
        setupStream()
        await captureService.configureSession(
            device: videoDevice,
            delegate: self
        )
        await zoom(to: 2.0)
    }

    func distributeDisplayFrames() async {
        guard let framesToDisplayStream else { return }
        for await imageBuffer in framesToDisplayStream {
            frameToDisplay = imageBuffer
        }
    }

    func distributeAnalyzeFrames() async {
        guard let framesToAnalyzeStream else { return }
        for await imageBuffer in framesToAnalyzeStream {
            await processFrame(imageBuffer)
            
            lastAnalyzedFrame = imageBuffer

            // CPU 부담저하를 위한 의도적 딜레이
            do {
                try await Task.sleep(for: Duration.milliseconds(1))
            } catch { return }
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
    
    private func setDefaultZoom() async {
        await zoom(to: 2.0)
    }

    private func processFrame(_ buffer: CVImageBuffer) async {
        do {
            let textRects = try await visionService.performTextRecognition(
                image: buffer
            )
            
            self.recognizedTextObservations = textRects
        } catch {
            print("Vision Processing Error !")
        }
    }

    private func setupStream() {
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
}

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
            framesToAnalyzeContinuation?.yield(imageBuffer)
        }
    }
}
