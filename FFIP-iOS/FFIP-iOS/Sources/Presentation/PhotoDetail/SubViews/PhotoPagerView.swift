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
                                    }
                                }
                                
                            }
                        }
                        .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(images.indices, id: \.self) { index in
                            if let image = UIImage(data: images[index].imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(
                                        width: index == selectedIndex ? 35 : 25,
                                        height: 35
                                    )
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(
                                                images[index].recognizedTexts != nil ? .ffipPointGreen1 : .clear,
                                                lineWidth: 1
                                            )
                                    }
                                    .cornerRadius(6)
                                    .id(index)
                                    .onTapGesture {
                                        withAnimation {
                                            selectedIndex = index
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, screenWidth / 2 - 15)
                    .padding(.vertical, 12)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if value.translation.width < -10 {
                                    if selectedIndex < images.count - 1 {
                                        selectedIndex += 1
                                        triggerHapticFeedback()
                                    }
                                } else if value.translation.width > 10 {
                                    if selectedIndex > 0 {
                                        selectedIndex -= 1
                                        triggerHapticFeedback()
                                    }
                                }
                            }
                    )
                }
                .onAppear {
                    DispatchQueue.main.async {
                        withAnimation {
                            proxy.scrollTo(selectedIndex, anchor: .center)
                        }
                    }
                }
                .onChange(of: selectedIndex) { _, newValue in
                    withAnimation {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
    }
}
