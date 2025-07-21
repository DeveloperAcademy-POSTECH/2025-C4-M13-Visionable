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
    let tipText1: AttributedString
    let tipText2: AttributedString
    let dontShowAgainText: AttributedString

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
                Image(.imgTipHaptic)

                Text(tipText1)
                    .font(.labelMedium16)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.ffipGrayScaleDefault2)

                Spacer()
                    .frame(height: 24)

                Image(.imgTipTap)

                Text(tipText2)

                Spacer()
                    .frame(height: 80)

                Button {
                    showTip = false
                    dontShowTipAgain = true
                } label: {
                    Text(dontShowAgainText)
                }
            }
        }
    }
}
