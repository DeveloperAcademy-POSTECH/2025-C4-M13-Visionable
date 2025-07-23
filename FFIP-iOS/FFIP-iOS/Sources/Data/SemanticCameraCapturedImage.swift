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
    
    init(
        id: UUID = UUID(),
        imageData: Data,
        createdAt: Date = .now
    ) {
        self.id = id
        self.imageData = imageData
        self.createdAt = createdAt
    }
}
