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
    var isShowSmudgeToast: Bool = false

    private(set) var recognizedTextObservations = [RecognizedTextObservation]()
    private(set) var matchedObservations = [RecognizedTextObservation]()
    private(set) var countDetectSmudge: Int = 0
    
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
    
    func distributeAnalyzeFrame(_ frameStream: AsyncStream<CVImageBuffer>?) async {
        guard let frameStream else { return }
        for await imageBuffer in frameStream {
            await processFrame(imageBuffer)
            if countDetectSmudge == 5 {
                isShowSmudgeToast = true
            }
            matchedObservations = filterMatchedObservations()
        }
    }
    
    func changeSearchKeyword(keyword: String) {
        searchKeyword = keyword
    }
}

private extension VisionModel {
    func processFrame(_ buffer: CVImageBuffer) async {
        do {
            if #available(iOS 26.0, *) {
                let isSmudge = try await visionService.performDetectSmudge(in: buffer, threshold: 0.95)
                if isSmudge {
                    countDetectSmudge += 1
                    if countDetectSmudge > 5 {
                        countDetectSmudge = 0
                    }
                    return
                } else {
                    countDetectSmudge = 0
                }
            }
            let textRects = try await visionService.performTextRecognition(image: buffer)
            self.recognizedTextObservations = textRects
        } catch {
            print("Vision Processing Error !")
        }
    }
    
    func filterMatchedObservations() -> [RecognizedTextObservation] {
        recognizedTextObservations.filter {
            if #available(iOS 26.0, *) {
                $0.transcript.localizedCaseInsensitiveContains(searchKeyword)
            } else {
                $0.topCandidates(1).first?.string.localizedCaseInsensitiveContains(searchKeyword) ?? false
            }
        }
    }
}
