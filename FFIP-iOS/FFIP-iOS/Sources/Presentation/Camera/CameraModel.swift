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

final class CameraModel: NSObject {
    private(set) var framesStream: AsyncStream<CVImageBuffer>?
    private(set) var analysisFramesStream: AsyncStream<CVImageBuffer>?
    private var framesStreamContinuation:
        AsyncStream<CVImageBuffer>.Continuation?
    private var analysisFramesStreamContinuation:
        AsyncStream<CVImageBuffer>.Continuation?

    private let privacyService: PrivacyService
    private let captureService: VideoCaptureService
    private let deviceService: VideoDeviceService

    private(set) var isCameraPaused: Bool = false
    
    init(
        privacyService: PrivacyService,
        captureService: VideoCaptureService,
        deviceService: VideoDeviceService
    ) {
        self.privacyService = privacyService
        self.captureService = captureService
        self.deviceService = deviceService
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
        await deviceService.setAutoFocusMode()
        await setDefaultZoom()
    }

    func stop() async {
        await captureService.stopSession()
        //        frame = nil
        framesStreamContinuation?.finish()
        analysisFramesStreamContinuation?.finish()
    }
}

// MARK: - CameraModel Private Extension Method
extension CameraModel {
    func setupStream() {
        framesStream = AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            self.framesStreamContinuation = continuation
        }
        analysisFramesStream = AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            self.analysisFramesStreamContinuation = continuation
        }
    }

    func zoom(to factor: CGFloat) async -> CGFloat {
        return await deviceService.zoom(to: factor)
    }

    func setDefaultZoom() async {
        _ = await zoom(to: 2.0)
    }

    func turnOffTorch() async -> Bool {
        await deviceService.turnOffTorch()
    }
    
    func turnOnTorch() async -> Bool {
        await deviceService.turnOnTorch()
    }
    
    func pauseCamera() {
        isCameraPaused = true
    }

    func resumeCamera() {
        isCameraPaused = false
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
            guard !isCameraPaused else { return }
            framesStreamContinuation?.yield(imageBuffer)
            analysisFramesStreamContinuation?.yield(imageBuffer)
        }
    }
}
