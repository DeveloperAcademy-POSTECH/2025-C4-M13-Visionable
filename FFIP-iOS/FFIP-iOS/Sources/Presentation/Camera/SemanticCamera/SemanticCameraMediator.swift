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
    private(set) var matchedObservations = [RecognizedTextObservation]()

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
        
        // TODO: - VisionModel에 현재 frame에서 추출한 String Array로 뽑기
        
        // TODO: - LangaugeModel에 추출한 String Array와 searchKeyword를 같이 요청 보내서 유사한 정보 받아오기

        // TODO: - matchedObservations와 비교해서 바운딩 박스 그리도록 준비하기
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
}
