//
//  VisionService.swift
//  FFIP-iOS
//
//  Created by mini on 7/9/25.
//

import Vision

actor VisionService {
    private var recognizeTextRequest = RecognizeTextRequest()
    private var aestheticRequest = CalculateImageAestheticsScoresRequest()

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

    func calculateAestheticScore(from buffer: CVImageBuffer) async throws
        -> Float {
        let observation = try await aestheticRequest.perform(on: buffer)
        let score = observation.overallScore

        return score
    }
}
