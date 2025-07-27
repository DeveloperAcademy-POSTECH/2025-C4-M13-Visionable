//
//  FfipBoundingBox.swift
//  FFIP-iOS
//
//  Created by mini on 7/15/25.
//

import SwiftUI
import Vision

// MARK: - 정규화 좌표에 맞춰 사각형을 그리기 위한 Box Shape
struct Box: Shape {
    private let normalizedRect: NormalizedRect
    
    init(observation: RecognizedTextObservation) {
        normalizedRect = observation.boundingBox
    }
    
    func path(in rect: CGRect) -> Path {
        let box = normalizedRect.toImageCoordinates(rect.size, origin: .upperLeft)
        return Path { path in
            path.addRect(box)
        }
    }
}

// MARK: - 실제 바운딩 박스의 디자인을 담당하는 뷰
struct FfipBoundingBox: View {
    private let observation: RecognizedTextObservation
    
    init(observation: RecognizedTextObservation) {
        self.observation = observation
    }
    
    var body: some View {
        GeometryReader { geo in
            let rect = observation.boundingBox.toImageCoordinates(geo.size, origin: .upperLeft)
            
            // 라인
            Box(observation: observation)
                .stroke(.ffipPointGreen1, lineWidth: 1.5)
            
            // 왼쪽 위 사각형
            Rectangle()
                .frame(width: 8, height: 8)
                .foregroundColor(.ffipPointGreen1)
                .position(x: rect.minX, y: rect.minY)
            
            // 왼쪽 아래 사각형
            Rectangle()
                .frame(width: 8, height: 8)
                .foregroundColor(.ffipPointGreen1)
                .position(x: rect.minX, y: rect.maxY)
            
            // 오른쪽 아래 사각형
            Rectangle()
                .frame(width: 8, height: 8)
                .foregroundColor(.ffipPointGreen1)
                .position(x: rect.maxX, y: rect.maxY)
            
            // 오른족 위 원
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(.ffipPointGreen1)
                .position(x: rect.maxX, y: rect.minY)
        }
    }
}
