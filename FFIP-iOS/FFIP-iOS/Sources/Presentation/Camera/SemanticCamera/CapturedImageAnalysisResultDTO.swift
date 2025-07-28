//
//  CapturedImageAnalysisResultDTO.swift
//  FFIP-iOS
//
//  Created by mini on 7/24/25.
//

import Foundation
import Vision

struct CapturedImageAnalysisResultDTO {
    let keyword: String?
    let similarity: Double
    let recognizedTexts: [RecognizedTextObservation]
}
