//
//  FfipCameraPopupTipOverlay.swift
//  FFIP-iOS
//
//  Created by mini on 7/26/25.
//

import SwiftUI
import Lottie

struct FfipCameraPopupTipOverlay: View {
    @Binding var showPopupTip: Bool
    @State private var currentTipPage: Int = 0
    let type: FfipCameraPopupTipType
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .onTapGesture { showPopupTip = false }
            
            VStack(spacing: 0) {
                Spacer()
                
                ZStack(alignment: .topTrailing) {
                    FfipCameraPopupTipCardView(currentTipPage: $currentTipPage, type: type)
                        .frame(height: 352)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                    
                    Button(action: { showPopupTip = false }) {
                        Image(.icnAlertClose)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 22)
                            .foregroundStyle(.ffipGrayscale1NoDark)
                            .padding(.top, 16)
                            .padding(.trailing, 55)
                    }
                }
                
                FfipPageControl(
                    style: .green,
                    totalCount: type.contents.count,
                    currentIndex: currentTipPage
                )
                
                Spacer(minLength: 195)
            }
        }
    }
}

struct FfipCameraPopupTipCardView: View {
    @Binding var currentTipPage: Int
    let type: FfipCameraPopupTipType
    
    var body: some View {
        VStack {
            TabView(selection: $currentTipPage) {
                ForEach(0..<type.contents.count, id: \.self) { index in
                    let content = type.contents[index]
                    
                    ZStack {
                        VStack(spacing: 0) {
                            Text(content.title)
                                .font(.titleBold20)
                                .foregroundStyle(.ffipGrayscale1NoDark)
                                .lineSpacing(2)
                                .padding(.bottom, 10)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                            
                            Text(content.description)
                                .font(.labelMedium14)
                                .foregroundStyle(.ffipGrayscale4)
                                                        
                            ZStack {
                                LottieView(animation: .named(content.lottieName))
                                    .looping()
                                    .frame(width: 250, height: 250)
                                
                                if type == .exact && index == 0 {
                                    Image(.onboardingIPhone)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 122)
                                        .padding(.top, 50)
                                }
                            }
                        }
                        .tag(index)
                    }
                    .padding(.top, 50)
                    .padding(.horizontal, 15)
                }
            }
            .frame(minWidth: 300)
            .background(.white)
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

enum FfipCameraPopupTipType {
    case exact
    
    var contents: [FfipCameraPopupTipModel] {
        switch self {
        case .exact: [
            FfipCameraPopupTipModel(
                title: String(localized:  "일정한 속도를 유지하세요"),
                description: String(localized: "더 정확한 탐색 결과를 얻을 수 있어요."),
                lottieName: LottieLiterals.Onboarding.scan
            ),
            FfipCameraPopupTipModel(
                title: String(localized: "줌 기능을 활용해보세요"),
                description: String(localized: "탐색 영역을 자유롭게 조정할 수 있어요."),
                lottieName: LottieLiterals.Onboarding.zoom
            ),
            FfipCameraPopupTipModel(
                title: String(localized: "화면을 멈추고 확인하세요"),
                description: String(localized: "두 번 연속 탭하면 진동과 FF!p 박스도 멈춰요."),
                lottieName: LottieLiterals.Onboarding.green
            )]
        }
    }
}

struct FfipCameraPopupTipModel: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let lottieName: String
}

// #Preview {
//     FfipCameraPopupTipOverlay(showPopupTip: .constant(true), type: .exact)
// }
