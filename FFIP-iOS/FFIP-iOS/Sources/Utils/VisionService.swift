//
//  VisionService.swift
//  FFIP-iOS
//
//  Created by mini on 7/9/25.
//

import Vision

actor VisionService {
    private let recognizeTextRequest: RecognizeTextRequest = {
        var request = RecognizeTextRequest()
        request.automaticallyDetectsLanguage = false
        request.recognitionLanguages = [
            Locale.Language(identifier: "ko-KR"),
            Locale.Language(identifier: "en-US")
        ]
        return request
    }()
    
    func performTextRecognition(image: CVImageBuffer) async throws -> [RecognizedTextObservation] {
        return try await recognizeTextRequest.perform(on: image)
    }
}
