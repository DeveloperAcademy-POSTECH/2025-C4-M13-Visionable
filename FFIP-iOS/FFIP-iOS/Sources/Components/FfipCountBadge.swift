//
//  FfipCountBadge.swift
//  FFIP-iOS
//
//  Created by mini on 7/27/25.
//

import SwiftUI

struct FfipCountBadge: View {
    var isLoading: Bool
    var count: Int
    
    var body: some View {
        Text("\(count)")
            .font(.onboardingBold16)
            .foregroundColor(.ffipGrayScaleDefault2)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 17)
                    .fill(isLoading ? .ffipGrayscale4 : .ffipPointGreen1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 17)
                    .stroke(.ffipGrayScaleDefault2, lineWidth: 1)
            )
            .frame(minWidth: 34, minHeight: 34)
            .fixedSize()
            .offset(x: -12, y: -12)
    }
}
