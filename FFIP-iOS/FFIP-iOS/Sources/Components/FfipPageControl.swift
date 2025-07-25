//
//  FfipPageControl.swift
//  FFIP-iOS
//
//  Created by mini on 7/22/25.
//

import SwiftUI

struct FfipPageControl: View {
    private let style: FfipPageControlStyle
    private let totalCount: Int
    private let currentIndex: Int
    
    public init(
        style: FfipPageControlStyle,
        totalCount: Int,
        currentIndex: Int
    ) {
        self.style = style
        self.totalCount = totalCount
        self.currentIndex = currentIndex
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: index == currentIndex ? 50 : 0)
                    .fill(index == currentIndex ? style.pointColor : .ffipGrayscale3)
                    .frame(width: 6, height: 6)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
                    .transition(.scale)
            }
        }
    }
}

enum FfipPageControlStyle {
    case black, green
    
    var pointColor: Color {
        switch self {
        case .black: .ffipGrayscale1
        case .green: .ffipPointGreen1
        }
    }
}

// #Preview {
//    FfipPageControl(totalCount: 4, currentIndex: 0)
// }
