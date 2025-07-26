//
//  ExampleModel.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import Foundation
import SwiftData
import Vision

@Model
final class SemanticCameraCapturedImage {
    @Attribute(.unique) var id: UUID
    @Attribute(.externalStorage) var imageData: Data
    var createdAt: Date
    var isAnalyzed: Bool
    var similarKeyword: String?
    var similarity: Double?
    var recognizedTexts: [RecognizedTextObservation]?

    init(
        id: UUID = UUID(),
        imageData: Data,
        createdAt: Date = .now,
        isAnalyzed: Bool = false
    ) {
        self.id = id
        self.imageData = imageData
        self.createdAt = createdAt
        self.isAnalyzed = isAnalyzed
    }
}
