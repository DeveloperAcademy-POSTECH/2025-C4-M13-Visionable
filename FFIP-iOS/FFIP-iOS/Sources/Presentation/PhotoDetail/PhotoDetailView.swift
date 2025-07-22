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
    @State private var isGridMode: Bool = false
    
    var body: some View {
        ZStack {
            Color.ffipBackground1Main
                .ignoresSafeArea()
            
            VStack {
                FfipNavigationBar(
                    leadingType: .back(action: { coordinator.pop() }),
                    centerType: isGridMode ? .none : .title(title: "어어어"),
                    trailingType: isGridMode ? .none : .grid(action: { isGridMode = true })
                )
                
                if isGridMode {
                    PhotoGridView(images: capturedImages) { index in
                        withAnimation {
                            selectedIndex = index
                            isGridMode = false
                        }
                    }
                } else {
                    PhotoPagerView(
                        images: capturedImages,
                        selectedIndex: $selectedIndex
                    )
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

// #Preview {
//    PhotoDetailView()
//        .environment(AppCoordinator())
// }
