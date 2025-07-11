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
    private(set) var imageBufferStream: AsyncStream<CVImageBuffer>?
    private var continuation: AsyncStream<CVImageBuffer>.Continuation?
    
    private(set) var recognizedTextObservations = [RecognizedTextObservation]()
    
    private let privacyService = PrivacyService()
    private let captureService = VideoCaptureService()
    private let deviceService = VideoDeviceService()
    private let visionService = VisionService()
    
    func start() async {
        await privacyService.fetchCameraAuthorization()
        await deviceService.fetchVideoDevice()
        guard let videoDevice = await deviceService.videoDevice else { return }
        await captureService.configureSession(device: videoDevice, delegate: self)
        setupStream()
    }
    
    func processFrame(_ buffer: CVImageBuffer) async {
        do {
            let textRects = try await visionService.performTextRecognition(image: buffer)
            await MainActor.run {
                self.recognizedTextObservations = textRects
            }
        } catch {
            print("Vision Processing Error !")
        }
    }
    
    private func setupStream() {
        imageBufferStream = AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            self.continuation = continuation
        }
    }
}

extension CameraModel: AVCaptureVideoDataOutputSampleBufferDelegate,
                       AVCaptureAudioDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard sampleBuffer.isValid, let imageBuffer = sampleBuffer.imageBuffer else { return }
        Task { @MainActor in
            continuation?.yield(imageBuffer)
        }
    }
}
