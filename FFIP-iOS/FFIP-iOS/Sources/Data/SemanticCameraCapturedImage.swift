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
    var similarKeyword: String
    var similarity: Double
    
    init(
        id: UUID = UUID(),
        imageData: Data,
        createdAt: Date = .now,
        similarKeyword: String,
        similarity: Double
    ) {
        self.id = id
        self.imageData = imageData
        self.createdAt = createdAt
        self.similarKeyword = similarKeyword
        self.similarity = similarity
    }
}
