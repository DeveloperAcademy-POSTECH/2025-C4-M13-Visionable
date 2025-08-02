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
                .accessibilityLabel("최근 탐색어 \(keyword)")
                .accessibilityHint("탭하면 카메라 뷰를 켜서 탐색을 시작합니다.")
                .accessibilityAddTraits(.isButton)
            
            Button(action: onTapDelete) {
                Image(.btnClose)
                    .tint(.ffipGrayscale2)
            }
            .accessibilityLabel("\(keyword) 삭제")
            .accessibilityHint("최근 탐색어 목록에서 이 항목을 제거합니다.")
            .accessibilityAddTraits(.isButton)
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
