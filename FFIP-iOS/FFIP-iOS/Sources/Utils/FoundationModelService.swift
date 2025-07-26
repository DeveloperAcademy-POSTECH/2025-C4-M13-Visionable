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
            instructions: "너는 OCR로 인식된 텍스트와 사용자가 찾는 키워드를 비교해 가장 유사한 키워드를 찾아줘야해."
        )
        
        let response = try await session.respond(generating: RelatedKeywords.self) {
            """
            다음은 OCR로 추출되어 인식된 키워드들이 모여있는 배열이야.
            [\(recognitionKeywords.joined(separator: ", "))]
                    
            recognitionKeywords 배열에 있는 키워드 중에서 "\(searchKeyword)"와 가장 유사한 단어를 찾아 "findKeyword" 필드에 담아주고, 
            \(searchKeyword)와의 유사도를 similarity 필드에 0~1 범위의 수치로 반환해줘.
            """
        }
        self.relatedKeywords = response.content
        print("📌 FoundationModel 유사 키워드 결과: \(response.content.findKeyword), 유사도: \(response.content.similarity)")
    }
}

@Generable
struct RelatedKeywords {
    let findKeyword: String
    @Guide(.range(0...1))
    let similarity: Double
}
