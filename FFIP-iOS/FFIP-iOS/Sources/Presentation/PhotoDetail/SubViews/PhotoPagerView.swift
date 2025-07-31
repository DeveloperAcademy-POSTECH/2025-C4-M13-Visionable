//
//  PhotoPagerView.swift
//  FFIP-iOS
//
//  Created by mini on 7/21/25.
//

import SwiftUI

struct PhotoPagerView: View {
    let images: [SemanticCameraCapturedImage]
    @Binding var selectedIndex: Int
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedIndex) {
                ForEach(images.indices, id: \.self) { index in
                    if let image = UIImage(data: images[index].imageData) {
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                            
                            GeometryReader { geo in
                                if let recognizedTexts = images[index].recognizedTexts {
                                    ForEach(recognizedTexts, id: \.self) { text in
                                        FfipBoundingBox(observation: text)
                                            .frame(width: geo.size.width, height: geo.size.height)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .stroke(
                                                        images[index].recognizedTexts == nil || !images[index].isAnalyzed
                                                        ? .clear
                                                        : .ffipPointGreen1,
                                                        lineWidth: 1
                                                    )
                                            }
                                    }
                                }
                            }
                        }
                        .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            ThumbnailCollectionViewRepresentable(
                images: images.compactMap { UIImage(data: $0.imageData) },
                selectedIndex: $selectedIndex
            )
            .frame(height: 40)
            .padding(.top, 12)
        }
    }
}
