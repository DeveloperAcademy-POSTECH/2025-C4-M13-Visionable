//
//  PhotoDetailView.swift
//  FFIP-iOS
//
//  Created by mini on 7/21/25.
//

import SwiftData
import SwiftUI

struct PhotoDetailView: View {
    @Environment(AppCoordinator.self) private var coordinator
    
    @Query(sort: \SemanticCameraCapturedImage.createdAt, order: .forward)
    private var capturedImages: [SemanticCameraCapturedImage]

    @State private var selectedIndex: Int = 0
    
    var body: some View {
        VStack {
            FfipNavigationBar(
                leadingType: .back(action: { coordinator.pop() }),
                centerType: .title(title: "어어어"),
                trailingType: .grid(action: { })
            )
            
            TabView(selection: $selectedIndex) {
                ForEach(capturedImages.indices, id: \.self) { index in
                    if let image = uiImage(for: index) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(capturedImages.indices, id: \.self) { index in
                            if let thumbnail = uiImage(for: index) {
                                Image(uiImage: thumbnail)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(
                                        width: index == selectedIndex ? 35 : 25,
                                        height: 35
                                    )
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
                    .padding(.horizontal, UIScreen.main.bounds.width / 2 - 15)
                    .padding(.vertical, 12)
                }
                .onChange(of: selectedIndex) { _, newValue in
                    withAnimation {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func uiImage(for index: Int) -> UIImage? {
        guard capturedImages.indices.contains(index) else { return nil }
        return UIImage(data: capturedImages[index].imageData)
    }
}

// #Preview {
//    PhotoDetailView()
//        .environment(AppCoordinator())
// }
