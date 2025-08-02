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

@Observable
final class VisionModel: NSObject {
    private let visionService: VisionService

    var searchKeyword: String

    private(set) var recognizedTextObservations = [RecognizedTextObservation]()
//    private(set) var matchedObservations = [RecognizedTextObservation]()

    init(
        searchKeyword: String,
        visionService: VisionService
    ) {
        self.searchKeyword = searchKeyword
        self.visionService = visionService
    }
}

extension VisionModel {
    func changeSearchKeyword(keyword: String) {
        searchKeyword = keyword
    }

    func prepare() async {
        await visionService.prepareTextRecognition(searchKeyword: searchKeyword)
    }
    
    func processFrame(_ buffer: CVImageBuffer) async {
        do {
            let textRects = try await visionService.performTextRecognition(image: buffer)
            self.recognizedTextObservations = textRects
        } catch {
            print("Vision Processing Error !")
        }
    }

    func filterMatchedObservations() -> [RecognizedTextObservation] {
        recognizedTextObservations.filter {
            $0.topCandidates(1).first?.string.localizedCaseInsensitiveContains(searchKeyword) ?? false
        }
    }
}
