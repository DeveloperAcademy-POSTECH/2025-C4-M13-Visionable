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
                .foregroundStyle(.black)
            
            Spacer()
            
            Button(action: onTapDelete) {
                Image(systemName: "xmark")
            }
            .tint(.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    RecentSearchRow(keyword: "최근 검색어", onTap: { print("클릭") }, onTapDelete: {})
}
