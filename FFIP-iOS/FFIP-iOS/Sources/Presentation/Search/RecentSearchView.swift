//
//  RecentSearchRow.swift
//  FFIP-iOS
//
//  Created by Jamin on 7/11/25.
//

import SwiftUI

struct RecentSearchView: View {
    var keyword: String
    var onTap: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onTap) {
                Text(keyword)
                    .foregroundStyle(.black)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark")
            }
            .tint(.black)
        }
    }
}

// #Preview {
//    RecentSearchView(keyword: "최근 검색어", onDelete: {})
// }
