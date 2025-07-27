//
//  CapturedImageStackView.swift
//  FFIP-iOS
//
//  Created by mini on 7/20/25.
//

import SwiftUI

struct CapturedImageStackView: View {
    let capturedImages: [SemanticCameraCapturedImage]
    
    private var isLoading: Bool {
        capturedImages.contains(where: { $0.isAnalyzed == false })
    }
    
    private var recognizedTextCount: Int {
        capturedImages
            .compactMap { $0.recognizedTexts?.count }
            .reduce(0, +)
    }

    var body: some View {
        ZStack {
            ForEach(
                Array(capturedImages.enumerated()),
                id: \.offset
            ) { index, image in
                
                if let uiImage = UIImage(data: image.imageData) {
                    let scale = 1.0 - CGFloat(index) * 0.06
                    let rotation = Double(index) * 4
                    let offsetX = CGFloat(index) * 6
                    let offsetY = CGFloat(index) * 6
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 88, height: 117)
                        .clipped()
                        .cornerRadius(4)
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(rotation))
                        .offset(x: offsetX, y: offsetY)
                        .zIndex(Double(capturedImages.count - index))
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        .animation(.easeOut(duration: 0.25), value: capturedImages.count)
                        .overlay(alignment: .topLeading) {
                            if index == 0 {
                                FfipCountBagde(
                                    isLoading: isLoading,
                                    count: recognizedTextCount
                                )
                            }
                        }
                }
            }
        }
        .frame(width: 117, height: 110)
    }
}

// #Preview {
//    let sampleImage = UIImage(resource: .mock)
//    let sampleData = sampleImage.jpegData(compressionQuality: 1.0)!
//    
//    CapturedImageStackView(capturedImages: [
//        SemanticCameraCapturedImage(imageData: sampleData),
//        SemanticCameraCapturedImage(imageData: sampleData),
//        SemanticCameraCapturedImage(imageData: sampleData),
//        SemanticCameraCapturedImage(imageData: sampleData)
//    ])
// }
