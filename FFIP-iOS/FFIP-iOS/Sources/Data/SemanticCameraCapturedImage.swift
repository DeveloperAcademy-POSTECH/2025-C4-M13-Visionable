//
//  ExampleModel.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import Foundation
import SwiftData

@Model
final class SemanticCameraCapturedImage {
    @Attribute(.unique) var id: UUID
    @Attribute(.externalStorage) var imageData: Data
    var createdAt: Date
    var similarKeyword: String?
    var similarity: Double?
    
    @Relationship var recognizedTexts: [RecognizedText]

    init(
        id: UUID = UUID(),
        imageData: Data,
        createdAt: Date = .now
    ) {
        self.id = id
        self.imageData = imageData
        self.createdAt = createdAt
        self.recognizedTexts = []
    }
}

@Model
final class RecognizedText {
    var text: String
    var boundingBox: BoundingBox
    @Relationship var parentImage: SemanticCameraCapturedImage?

    init(text: String, boundingBox: BoundingBox) {
        self.text = text
        self.boundingBox = boundingBox
    }
}

@Model
final class BoundingBox {
    var x: Double
    var y: Double
    var width: Double
    var height: Double
    
    init(rect: CGRect) {
        self.x = rect.origin.x
        self.y = rect.origin.y
        self.width = rect.size.width
        self.height = rect.size.height
    }
}
