//
//  WidgetNoticeView.swift
//  FFIP-iOS
//
//  Created by mini on 8/20/25.
//

import SwiftUI

struct WidgetNoticeView: View {
    let addWidgetButtonTapped: () -> Void
    let passButtonTapped: () -> Void
    
    var body: some View {
        VStack {
            Text(.noticeWidgetSheetTitle)
                .font(.titleBold20)
                .foregroundStyle(.ffipGrayscale1)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 34)

            Image(.imgWidgetSheet)
                .padding(.top, 12)
            
            FfipButton(title: String(localized: .addWidget)) {
                addWidgetButtonTapped()
            }
            .padding(.bottom, 4)
            
            Button(action: { passButtonTapped() }) {
                Text(.passButton)
                    .font(.titleSemiBold16)
                    .foregroundStyle(.ffipGrayscale4)
            }
            .padding(.bottom, 42)
        }
        .background(.ffipBackground2Modal)
    }
}

#Preview {
    VStack {
        Spacer()
        FfipBottomSheet {
            WidgetNoticeView(addWidgetButtonTapped: {}, passButtonTapped: {})
        }
    }.background(.gray)
        .ignoresSafeArea()
}
