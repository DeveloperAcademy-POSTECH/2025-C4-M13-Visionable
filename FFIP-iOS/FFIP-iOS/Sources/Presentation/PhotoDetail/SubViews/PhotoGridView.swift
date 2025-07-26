//
//  PhotoGridView.swift
//  FFIP-iOS
//
//  Created by mini on 7/21/25.
//

import SwiftUI

struct PhotoGridView: View {
    let images: [SemanticCameraCapturedImage]
    let onSelect: (Int) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 50),
        GridItem(.flexible(), spacing: 50)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 18) {
                ForEach(images.indices, id: \.self) { index in
                    if let image = UIImage(data: images[index].imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(13/17, contentMode: .fill)
                            .cornerRadius(4)
                            .onTapGesture { onSelect(index) }
                            .overlay {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(
                                        images[index].recognizedTexts != nil ? .ffipPointGreen1 : .clear,
                                        lineWidth: 1
                                    )
                                
                                if images[index].isAnalyzed == false {
                                    Color.black.opacity(0.3)
                                        .cornerRadius(4)
                                    
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            }
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 12)
        }
    }
}
