//
//  FoundationModelService.swift
//  FFIP-iOS
//
//  Created by mini on 7/14/25.
//

import FoundationModels

actor FoundationModelsService {
    private(set) var relatedKeywords: RelatedKeywords?
    // private let session: LanguageModelSession
    
//    init() {
//        self.session = LanguageModelSession(
//            instructions: "너는 OCR로 인식된 텍스트와 사용자가 찾는 키워드를 비교해 가장 유사한 키워드를 찾아줘야해."
//        )
//    }
    
    func findRelatedKeywords(
        searchKeyword: String,
        recognitionKeywords: [String]
    ) async throws {
        let session = LanguageModelSession(
            instructions: "base: [\(recognitionKeywords.joined(separator: ", "))]"
        )
        
        let response = try await session.respond(generating: RelatedKeywords.self) {
            "base 중, \"\(searchKeyword)\"요청에 알맞는 키워드를 찾아라."
        }
        self.relatedKeywords = response.content
//        print("📌 FoundationModel 유사 키워드 결과: \(response.content.findKeyword), 유사도: \(response.content.similarity)")
    }
}

@Generable
struct RelatedKeywords {
    let findKeyword: String
    @Guide(.range(0...1))
    let similarity: Double
}
