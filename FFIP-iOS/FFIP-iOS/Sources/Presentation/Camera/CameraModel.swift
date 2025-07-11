//
//  CameraModel.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

@preconcurrency import AVFoundation
import Photos
import SwiftUI

@MainActor
@Observable
final class CameraModel: NSObject {
    private(set) var imageBufferStream: AsyncStream<CVImageBuffer>?
    
    private var continuation: AsyncStream<CVImageBuffer>.Continuation?
    private(set) var frame: CVImageBuffer?
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
    }
    
    private func processFrame(_ buffer: CVImageBuffer) {
        Task {
            do {
                let textRects = try await visionService.performTextRecognition(image: buffer)
                await MainActor.run {
                    self.recognizedTextObservations = textRects
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
            self.frame = sampleBuffer.imageBuffer
            self.processFrame(imageBuffer)
                continuation?.yield(imageBuffer)
        }
    }
}
