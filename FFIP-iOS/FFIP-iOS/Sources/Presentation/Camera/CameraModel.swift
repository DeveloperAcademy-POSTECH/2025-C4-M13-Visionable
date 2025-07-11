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
    
    private let privacyService = PrivacyService()
    private let captureService = VideoCaptureService()
    private let deviceService = VideoDeviceService()

    func start() async {
        await privacyService.fetchCameraAuthorization()
        await deviceService.fetchVideoDevice()
        
        guard let videoDevice = await deviceService.videoDevice else { return }
        await captureService.configureSession(
            device: videoDevice,
            delegate: self
        )
        
        setupStream()
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
        if sampleBuffer.isValid && sampleBuffer.imageBuffer != nil {
            Task { @MainActor in
                guard let imageBuffer = sampleBuffer.imageBuffer else { return }
                continuation?.yield(imageBuffer)
            }
        }
    }
}
