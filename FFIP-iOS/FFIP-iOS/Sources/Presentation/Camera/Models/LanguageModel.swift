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
}
