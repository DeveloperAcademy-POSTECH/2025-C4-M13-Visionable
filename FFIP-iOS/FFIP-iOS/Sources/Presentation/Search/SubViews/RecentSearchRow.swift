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
                .accessibilityLabel("최근 탐색어 \(keyword)")
                .accessibilityHint("탭하면 카메라 뷰를 켜서 탐색을 시작합니다.")
                .accessibilityAddTraits(.isButton)
            
            Spacer()
            
            Button(action: onTapDelete) {
                Image(systemName: "xmark")
            }
            .frame(width: 20, height: 20)
            .tint(.gray)
            .accessibilityLabel("\(keyword) 삭제")
            .accessibilityHint("최근 탐색어 목록에서 이 항목을 제거합니다.")
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
