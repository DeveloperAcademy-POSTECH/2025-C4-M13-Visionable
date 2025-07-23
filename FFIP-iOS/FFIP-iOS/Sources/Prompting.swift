//
//  Prompting.swift
//  FFIP-iOS
//
//  Created by mini on 7/14/25.
//

import Playgrounds
import FoundationModels

#Playground {
    let detectedKeywords: [String] = ["부산 뜨겁다.", "너 글씨가 너무 자가", "음", "너 글씨가", "너무 작아"]
    let keyword = "부산 뜨겁다"
    
    let session = LanguageModelSession()
    
    let resopnse = try await session.respond(
        to: """
        다음은 OCR로 추출되어 인식된 키워드들이 모여있는 배열이야.
        [\(detectedKeywords.joined(separator: ", "))]
                
        위 배열에서 "\(keyword)"와 가장 유사한 키워드를 찾아주고, 유사도를 similarity에 수치로 보여줘
        """,
        generating: Result.self
    )
}

@Generable
struct Result {
    let findKeyword: String
    
    @Guide(.range(0...100))
    let similarity: Double
}
