//
//  RelatedCameraMediator.swift
//  FFIP-iOS
//
//  Created by SeanCho on 7/18/25.
//

@preconcurrency import AVFoundation
import SwiftUI
import Vision

@MainActor
@Observable
final class SemanticCameraMediator: NSObject {
    private(set) var frame: CVImageBuffer?
    
    private(set) var zoomFactor: CGFloat = 2.0
    private(set) var isCameraPaused: Bool = false
    private(set) var isTorchOn: Bool = false
    
    private let cameraModel: CameraModel
    var visionModel: VisionModel
    private let languageModel: LanguageModel
    
    init(
        cameraModel: CameraModel,
        visionModel: VisionModel,
        languageModel: LanguageModel
    ) {
        self.cameraModel = cameraModel
        self.visionModel = visionModel
        self.languageModel = languageModel
    }
    
    func start() async {
        await cameraModel.start()
        await visionModel.prepare()
        
        guard let framesStream = cameraModel.framesStream else { return }
        Task {
            for await imageBuffer in framesStream {
                frame = imageBuffer
            }
        }
    }
    
    func stop() async {
        await cameraModel.stop()
    }
    
    func zoom(to factor: CGFloat) async {
        zoomFactor = await cameraModel.zoom(to: factor)
    }
    
    func pauseCamera() {
        isCameraPaused = true
        cameraModel.pauseCamera()
    }
    
    func resumeCamera() {
        isCameraPaused = false
        cameraModel.resumeCamera()
    }
    
    func toggleTorch() async {
        if isTorchOn {
            isTorchOn = await cameraModel.turnOffTorch()
        } else {
            isTorchOn = await cameraModel.turnOnTorch()
        }
    }
    
    func analyzeCapturedImage(_ imageBuffer: CVImageBuffer) async -> CapturedImageAnalysisResultDTO? {
        await visionModel.processFrame(imageBuffer)
        let recognizedTexts = visionModel.recognizedTextObservations.map { $0.transcript }
        print("searchKeyword:", visionModel.searchKeyword)
        print("recognizedTexts:", recognizedTexts)
        
        guard let result = try? await languageModel.findMostSimilarKeywordWithScore(
            to: visionModel.searchKeyword,
            from: recognizedTexts
        ) else {
            return nil
        }
                
        return CapturedImageAnalysisResultDTO(
            keyword: result.keyword,
            similarity: result.similarity,
            recognizedTexts: visionModel.recognizedTextObservations
        )
    }
}
