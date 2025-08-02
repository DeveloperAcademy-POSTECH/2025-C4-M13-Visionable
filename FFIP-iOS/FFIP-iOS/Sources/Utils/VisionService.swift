//
//  VisionService.swift
//  FFIP-iOS
//
//  Created by mini on 7/9/25.
//

import SwiftUI
import Vision

actor VisionService {
    private var recognizeTextRequest = RecognizeTextRequest()
    
    func prepareTextRecognition(searchKeyword: String) {
        recognizeTextRequest.minimumTextHeightFraction = 0.01
        recognizeTextRequest.automaticallyDetectsLanguage = false
        recognizeTextRequest.recognitionLanguages = [
            Locale.Language(identifier: "ko-KR"),
            Locale.Language(identifier: "en-US")
        ]
        recognizeTextRequest.customWords.append(searchKeyword)
    }
    
    func performTextRecognition(
        image: CVImageBuffer
    ) async throws -> [RecognizedTextObservation] {
        return try await recognizeTextRequest.perform(on: image)
    }
    
    func performTextRecognition(
        imageData: Data
    ) async throws -> [RecognizedTextObservation] {
        return try await recognizeTextRequest.perform(on: imageData)
    }
    
    func recognizedTexts(observations: [RecognizedTextObservation]) -> [String] {
        observations.map {
            $0.topCandidates(1).first?.string ?? ""
        }
    }
}
