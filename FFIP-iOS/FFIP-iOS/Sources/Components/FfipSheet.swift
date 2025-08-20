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
                .frame(width: 40, height: 3)
                .padding(.top, 8)

            content
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ffipBackground2Modal)
        )
    }
}
