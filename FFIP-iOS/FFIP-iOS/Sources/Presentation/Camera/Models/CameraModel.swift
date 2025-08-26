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

@Observable
final class CameraModel: NSObject {
    private(set) var frame: CVImageBuffer?

    private(set) var framesStream: AsyncStream<CVImageBuffer>?
    private(set) var analysisFramesStream: AsyncStream<CVImageBuffer>?
    private var framesStreamContinuation:
        AsyncStream<CVImageBuffer>.Continuation?
    private var analysisFramesStreamContinuation:
        AsyncStream<CVImageBuffer>.Continuation?
    
    private(set) var isCameraPaused: Bool = false
    private(set) var isTorchOn: Bool = false
    private(set) var zoomFactor: CGFloat = 2.0

    private let privacyService: PrivacyService
    private let captureService: VideoCaptureService
    private let deviceService: VideoDeviceService
    
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
        setupStreams()
        await captureService.configureSession(device: videoDevice, delegate: self)
        await deviceService.setAutoFocusMode()
        await zoom(to: zoomFactor)
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
    @MainActor
    func distributeDisplayFrame() async {
        guard let framesStream else { return }
        for await imageBuffer in framesStream {
            frame = imageBuffer
        }
    }
    
    func zoom(to factor: CGFloat) async {
        guard !isCameraPaused else { return }
        zoomFactor = await deviceService.zoom(to: factor)
    }

    func handleZoomButtonTapped() async {
        if zoomFactor > 4.0 {
            await zoom(to: 4.0)
        } else if zoomFactor == 4.0 {
            await zoom(to: 1.0)
        } else if zoomFactor > 2.0 {
            await zoom(to: 2.0)
        } else if zoomFactor == 2.0 {
            await zoom(to: 4.0)
        } else if zoomFactor == 1.0 {
            await zoom(to: 2.0)
        } else {
            await zoom(to: 1.0)
        }
    }
    
    func toggleTorch() async {
        if isTorchOn {
            isTorchOn = await deviceService.turnOffTorch()
        } else {
            isTorchOn = await deviceService.turnOnTorch()
        }
    }
    
    func pauseCamera() {
        isCameraPaused = true
    }

    func resumeCamera() {
        isCameraPaused = false
    }
}

private extension CameraModel {
    func setupStreams() {
        framesStream = AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            self.framesStreamContinuation = continuation
        }
        analysisFramesStream = AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            self.analysisFramesStreamContinuation = continuation
        }
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
