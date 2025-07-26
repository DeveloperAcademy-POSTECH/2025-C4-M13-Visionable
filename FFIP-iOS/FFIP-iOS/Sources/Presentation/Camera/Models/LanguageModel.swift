//
//  LanguageModel.swift
//  FFIP-iOS
//
//  Created by mini on 7/21/25.
//

import Foundation

final class LanguageModel: NSObject {
    private let foundationModelsService: FoundationModelsService

    init(
        foundationModelsService: FoundationModelsService
    ) {
        self.foundationModelsService = foundationModelsService
    }
    
    /// 인식된 키워드 배열 중 searchKeyword와 가장 유사한 키워드를 반환
    func findMostSimilarKeyword(
        to searchKeyword: String,
        from recognitionKeywords: [String]
    ) async throws -> String? {
        try await foundationModelsService.findRelatedKeywords(
            searchKeyword: searchKeyword,
            recognitionKeywords: recognitionKeywords
        )

        return await foundationModelsService.relatedKeywords?.findKeyword
    }

    /// 필요시 유사도까지 반환하는 메서드도 추가 가능
    func findMostSimilarKeywordWithScore(
        to searchKeyword: String,
        from recognitionKeywords: [String]
    ) async throws -> (keyword: String, similarity: Double)? {
        try await foundationModelsService.findRelatedKeywords(
            searchKeyword: searchKeyword,
            recognitionKeywords: recognitionKeywords
        )

        if let result = await foundationModelsService.relatedKeywords {
            return (result.findKeyword, result.similarity)
        } else {
            return nil
        }
    }
}
