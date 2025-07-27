//
//  FfipCountBagde.swift
//  FFIP-iOS
//
//  Created by mini on 7/27/25.
//

import SwiftUI

struct FfipCountBagde: View {
    var isLoading: Bool
    var count: Int
    
    var body: some View {
        Text("\(count)")
            .font(.onboardingBold16)
            .foregroundColor(.ffipGrayScaleDefault2)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isLoading ? .ffipGrayscale4 : .ffipPointGreen1)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(.ffipGrayScaleDefault2, lineWidth: 1)
            )
            .offset(x: -12, y: -12)
            .frame(width: 34, height: 34)
    }
}
