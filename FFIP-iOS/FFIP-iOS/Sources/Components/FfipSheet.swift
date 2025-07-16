//
//  FfipSheet.swift
//  FFIP-iOS
//
//  Created by mini on 7/15/25.
//

import SwiftUI

struct FfipBottomSheet<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(.ffipGrayscale4)
                .frame(width: 49, height: 4)
                .padding(.top, 6)

            content
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 60)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ffipBackground2Modal)
        )
    }
}
