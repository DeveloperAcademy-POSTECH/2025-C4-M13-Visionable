//
//  FfipCameraPopupTipOverlay.swift
//  FFIP-iOS
//
//  Created by mini on 7/26/25.
//

import SwiftUI

struct FfipCameraPopupTipOverlay: View {
    @Binding var showPopupTip: Bool
    @State private var currentTipPage: Int = 0
    let type: FfipCameraPopupTipType
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
            VStack {
                HStack {
                    Spacer()
                    //                    FfipCloseButton(action: { showPopupTip = false })
                    //                        .padding(.trailing, 20)
                    //                        .padding(.top, 67)
                }
                Spacer()
            }
            
            VStack(spacing: 12) {
                Spacer()
                
                TabView(selection: $currentTipPage) {
                    ForEach(type.contents.indices, id: \.self) { index in
                        FfipCameraPopupTipCardView(page: type.contents[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 420)
                
                HStack(spacing: 8) {
                    ForEach(type.contents.indices, id: \.self) { index in
                        Circle()
                            .fill(index == currentTipPage ? Color.green : Color.gray.opacity(0.4))
                            .frame(width: 6, height: 6)
                    }
                }
                
                Spacer()
            }
        }
        .animation(.easeInOut, value: currentTipPage)
    }
    
}

struct FfipCameraPopupTipCardView: View {
    let page: FfipCameraPopupTipModel
    
    var body: some View {
        VStack {
            Text(page.title)
            Text(page.description)
            Image(page.imageName)
        }
        .padding()
        .frame(minWidth: 300)
        .background(.white)
        .cornerRadius(20)
    }
}

enum FfipCameraPopupTipType {
    case exact, semantic
    
    var contents: [FfipCameraPopupTipModel] {
        switch self {
        case .exact: [
            FfipCameraPopupTipModel(
                title: String(localized: .exactCameraPopupTip1Title),
                description: String(localized: .exactCameraPopupTip1Title),
                imageName: .mock
            ),
            FfipCameraPopupTipModel(
                title: String(localized: .exactCameraPopupTip2Title),
                description: String(localized: .exactCameraPopupTip2Title),
                imageName: .mock
            ),
            FfipCameraPopupTipModel(
                title: String(localized: .exactCameraPopupTip3Title),
                description: String(localized: .exactCameraPopupTip3Title),
                imageName: .mock
            )]
            
        case .semantic: [
            FfipCameraPopupTipModel(
                title: String(localized: .semanticCameraPopupTip1Title),
                description: String(localized: .semanticCameraPopupTip1Description),
                imageName: .mock
            ),
            FfipCameraPopupTipModel(
                title: String(localized: .semanticCameraPopupTip2Title),
                description: String(localized: .semanticCameraPopupTip2Description),
                imageName: .mock
            ),
            FfipCameraPopupTipModel(
                title: String(localized: .semanticCameraPopupTip3Title),
                description: String(localized: .semanticCameraPopupTip3Description),
                imageName: .mock
            )]
        }
    }
}

struct FfipCameraPopupTipModel: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: ImageResource
}

#Preview {
    FfipCameraPopupTipOverlay(showPopupTip: .constant(true), type: .exact)
}
