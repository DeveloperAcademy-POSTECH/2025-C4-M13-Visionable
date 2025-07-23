//
//  CameraTipOverlay.swift
//  FFIP-iOS
//
//  Created by SeanCho on 7/21/25.
//

import SwiftUI

struct FfipCameraTipOverlay: View {
    @Binding var showTip: Bool
    @Binding var dontShowTipAgain: Bool
    
    let ffipCameraTipType: FfipCameraTipType
    let tipText1: AttributedString
    let tipText2: AttributedString
    let dontShowAgainText: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
            VStack {
                HStack {
                    Spacer()
                    FfipCloseButton(action: { showTip = false })
                        .padding(.trailing, 20)
                        .padding(.top, 67)
                }
                Spacer()
            }

            VStack(spacing: 12) {
                Image(ffipCameraTipType.firstTipImage)

                Text(tipText1)
                    .font(.labelMedium16)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.ffipGrayScaleDefault2)

                Spacer()
                    .frame(height: 24)

                Image(ffipCameraTipType.secondTipImage)

                Text(tipText2)
                    .font(.labelMedium16)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.ffipGrayScaleDefault2)

                Spacer()
                    .frame(height: 80)

                Button {
                    showTip = false
                    dontShowTipAgain = true
                } label: {
                    Text(dontShowAgainText)
                        .font(.labelMedium14)
                        .underline(true, pattern: .solid)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
}

// MARK: - Toast Type Enum
public enum FfipCameraTipType {
    case exact, semantic
    
    var firstTipImage: ImageResource {
        switch self {
        case .exact: .imgTipHaptic
        case .semantic: .imgTipTap
        }
    }
    
    var secondTipImage: ImageResource {
        switch self {
        case .exact: .imgTipTap
        case .semantic: .imgTipSnapbook
        }
    }
}
