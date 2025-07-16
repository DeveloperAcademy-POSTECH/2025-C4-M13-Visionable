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
    
    private(set) var searchKeyword: String
    private(set) var isRelatedSearchMode: Bool = true
    private(set) var recognizedTextObservations = [RecognizedTextObservation]()
    private(set) var matchedObservations = [RecognizedTextObservation]()
    
    private(set) var isCameraPaused: Bool = false
    private(set) var zoomFactor: CGFloat = 2.0
    private(set) var isTorchOn: Bool = false
    
    private var framesToDisplayStream: AsyncStream<CVImageBuffer>?
    private var framesToAnalyzeStream: AsyncStream<CVImageBuffer>?
    private var framesToDisplayContinuation:
    AsyncStream<CVImageBuffer>.Continuation?
    private var framesToAnalyzeContinuation:
    AsyncStream<CVImageBuffer>.Continuation?
    
    private let foundationModelsService: FoundationModelsService
    private let privacyService: PrivacyService
    private let captureService: VideoCaptureService
    private let deviceService: VideoDeviceService
    private let visionService: VisionService
    
    init(
        searchKeyword: String,
        foundationModelsService: FoundationModelsService,
        privacyService: PrivacyService,
        captureService: VideoCaptureService,
        deviceService: VideoDeviceService,
        visionService: VisionService,
    ) {
        self.searchKeyword = searchKeyword
        self.foundationModelsService = foundationModelsService
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
    }
    
    func stop() async {
        await captureService.stopSession()
        framesToDisplayContinuation?.finish()
        framesToAnalyzeContinuation?.finish()
        framesToDisplayStream = nil
        framesToAnalyzeStream = nil
        framesToDisplayContinuation = nil
        framesToAnalyzeContinuation = nil
        recognizedTextObservations = []
        matchedObservations = []
        frameToDisplay = nil
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
            await processFrame(imageBuffer)
                        
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
    
    func pauseCamera() {
        isCameraPaused = true
    }
    
    func resumeCamera() {
        isCameraPaused = false
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
            self.recognizedTextObservations = textRects
            
            if isRelatedSearchMode {
                await filterRelatedKeywordObservations(recognizedTexts: textRects.map { $0.transcript })
            } else {
                filterMatchedObservations(searchKeyword: searchKeyword)
            }
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
    
    func filterMatchedObservations(searchKeyword: String) {
        matchedObservations = recognizedTextObservations.filter {
            $0.transcript.localizedCaseInsensitiveContains(searchKeyword)
        }
    }
    
    func filterRelatedKeywordObservations(recognizedTexts: [String]) async {
        guard !recognizedTexts.isEmpty else { return }
        do {
            try await foundationModelsService.findRelatedKeywords(
                searchKeyword: self.searchKeyword,
                recognitionKeywords: recognizedTexts
            )
            guard let findKeyword = await foundationModelsService.relatedKeywords?.findKeyword else { return }
            filterMatchedObservations(searchKeyword: findKeyword)
        } catch {
            print("FoundationModelsService Error: \(error)")
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
            guard !isCameraPaused else { return }
            framesToDisplayContinuation?.yield(imageBuffer)
            framesToAnalyzeContinuation?.yield(imageBuffer)
        }
    }
}
