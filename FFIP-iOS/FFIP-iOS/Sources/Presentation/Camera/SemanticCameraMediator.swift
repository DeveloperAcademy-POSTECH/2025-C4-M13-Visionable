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
    private let visionModel: VisionModel

    init(
        cameraModel: CameraModel,
        visionModel: VisionModel
    ) {
        self.cameraModel = cameraModel
        self.visionModel = visionModel
    }

    func start() async {
        await cameraModel.start()

        guard let framesStream = cameraModel.framesStream else { return }
        Task {
            for await imageBuffer in framesStream {
                frame = imageBuffer
            }
        }

        Task {
            for await imageBuffer in framesStream {
                await visionModel.processFrame(imageBuffer)
                matchedObservations = visionModel.matchedObservations
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
}
