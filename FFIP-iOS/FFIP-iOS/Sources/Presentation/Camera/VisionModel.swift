//
//  VisionModel.swift
//  FFIP-iOS
//
//  Created by SeanCho on 7/18/25.
//

@preconcurrency import AVFoundation
import Photos
import SwiftUI
import Vision

final class VisionModel: NSObject {
    private let visionService: VisionService

    private(set) var searchKeyword: String

    private(set) var recognizedTextObservations = [RecognizedTextObservation]()
    private(set) var matchedObservations = [RecognizedTextObservation]()

    init(
        searchKeyword: String,
        visionService: VisionService
    ) {
        self.searchKeyword = searchKeyword
        self.visionService = visionService
    }
}

extension VisionModel {
    func prepare() async {
        await visionService.prepareTextRecognition(searchKeyword: searchKeyword)
    }
    
    func processFrame(_ buffer: CVImageBuffer) async {
        do {
            let textRects = try await visionService.performTextRecognition(
                image: buffer
            )

            self.recognizedTextObservations = textRects
            filterMatchedObservations()
        } catch {
            print("Vision Processing Error !")
        }
    }

    func filterMatchedObservations() {
        matchedObservations = recognizedTextObservations.filter {
            $0.transcript.localizedCaseInsensitiveContains(searchKeyword)
        }
    }
}
