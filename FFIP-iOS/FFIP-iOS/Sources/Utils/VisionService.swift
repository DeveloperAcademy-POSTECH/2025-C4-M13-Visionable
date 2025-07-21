//
//  VisionService.swift
//  FFIP-iOS
//
//  Created by mini on 7/9/25.
//

import Vision

actor VisionService {
    func performTextRecognition(
        image: CVImageBuffer,
        customWords: String
    ) async throws -> [RecognizedTextObservation] {
        var recognizeTextRequest = RecognizeTextRequest()
        recognizeTextRequest.automaticallyDetectsLanguage = false
        recognizeTextRequest.recognitionLanguages = [
            Locale.Language(identifier: "ko-KR"),
            Locale.Language(identifier: "en-US")
        ]
        recognizeTextRequest.customWords.append(customWords)
        return try await recognizeTextRequest.perform(on: image)
    }
    
    func recognizedTexts(observations: [RecognizedTextObservation]) -> [String] {
        observations.map { $0.transcript }
    }
}
