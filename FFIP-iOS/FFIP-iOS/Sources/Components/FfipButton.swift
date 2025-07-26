//
//  FfipButton.swift
//  FFIP-iOS
//
//  Created by mini on 7/22/25.
//

import SwiftUI

struct FfipButton: View {
    private let title: String
    private let action: () -> Void
    
    public init(
        title: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.titleSemiBold16)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, maxHeight: 56)
                .foregroundStyle(.ffipBackground1Main)
                .background(.ffipGrayscale1)
                .cornerRadius(8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

// #Preview {
//    FfipButton(title: "어저구", action: {})
// }
