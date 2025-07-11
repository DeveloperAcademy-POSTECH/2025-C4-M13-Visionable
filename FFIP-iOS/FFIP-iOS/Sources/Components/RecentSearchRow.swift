//
//  RecentSearchRow.swift
//  FFIP-iOS
//
//  Created by Jamin on 7/11/25.
//

import SwiftUI

struct RecentSearchRow: View {
    var keyword: String
    var onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(keyword)
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "xmark")
            }
            .tint(.black)
        }
    }
}

#Preview {
    RecentSearchRow(keyword: "최근 검색어", onDelete: {})
}
