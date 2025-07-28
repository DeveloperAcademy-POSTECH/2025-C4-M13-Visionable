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
    private let detectLensSmudgeRequest = DetectLensSmudgeRequest()
    
    func prepareTextRecognition(searchKeyword: String) {
        recognizeTextRequest.minimumTextHeightFraction = 0.01
        recognizeTextRequest.automaticallyDetectsLanguage = false
        recognizeTextRequest.recognitionLanguages = [
            Locale.Language(identifier: "ko-KR"),
            Locale.Language(identifier: "en-US")
        ]
        recognizeTextRequest.customWords.append(searchKeyword)
    }

    func performDetectSmudge(in imageBuffer: CVImageBuffer, threshold: Float) async throws -> Bool {
        let smudgeObservation = try await detectLensSmudgeRequest.perform(on: imageBuffer)
        let confidence = smudgeObservation.confidence
        
        if confidence > threshold {
            return true
        } else {
            return false
        }
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
        observations.map { $0.transcript }
    }
}
