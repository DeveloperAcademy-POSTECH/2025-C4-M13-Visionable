//
//  RecentSearchRow.swift
//  FFIP-iOS
//
//  Created by Jamin on 7/11/25.
//

import SwiftUI

struct RecentSearchRow: View {
    var keyword: String
    var onTap: () -> Void
    var onTapDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(keyword)
                .foregroundStyle(.ffipGrayscale1)
                .lineLimit(1)
                .accessibilityLabel(.VoiceOverLocalizable.recentKeyword(keyword))
                .accessibilityHint(.VoiceOverLocalizable.searchCapsule)
                .accessibilityAddTraits(.isButton)
            
            Spacer()
            
            Button(action: onTapDelete) {
                Image(systemName: "xmark")
            }
            .frame(width: 20, height: 20)
            .tint(.gray)
            .accessibilityLabel(.VoiceOverLocalizable.delete(keyword))
            .accessibilityHint(.VoiceOverLocalizable.deleteRecentKeyword)
            .accessibilityAddTraits(.isButton)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// #Preview {
//    RecentSearchRow(keyword: "검색어최근 검색어최근 검색어최근 검색어최근 검색어최근 검색어", onTap: { print("클릭") }, onTapDelete: {})
// }
