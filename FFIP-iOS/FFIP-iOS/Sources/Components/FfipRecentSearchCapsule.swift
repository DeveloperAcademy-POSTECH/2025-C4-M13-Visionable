//
//  RecentSearchCapsule.swift
//  FFIP-iOS
//
//  Created by Jamin on 7/14/25.
//

import SwiftUI

struct FfipRecentSearchCapsule: View {
    var keyword: String
    var onTap: () -> Void
    var onTapDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Text(keyword)
                .font(.labelMedium14)
                .foregroundStyle(.ffipGrayscale1)
                .lineLimit(1)
            
            Button(action: onTapDelete) {
                Image(.btnClose)
                    .tint(.ffipGrayscale2)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 50)
                .fill(.clear)
                .stroke(.ffipGrayscale4, lineWidth: 1)
        )
        .onTapGesture {
            onTap()
        }
    }
}

// #Preview {
//    FfipRecentSearchCapsule(keyword: "텍스트가 들어갑니다텍스트가 들어갑니다텍스트가 들어갑니다텍스트가 들어갑니다", onTap: {}, onTapDelete: {})
// }
