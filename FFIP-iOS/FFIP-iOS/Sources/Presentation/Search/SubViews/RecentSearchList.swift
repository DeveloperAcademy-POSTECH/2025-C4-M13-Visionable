//
//  RecentSearchList.swift
//  FFIP-iOS
//
//  Created by Jamin on 7/20/25.
//

import SwiftUI

struct RecentSearchList: View {
    let keywords: [String]
    let onTap: (String) -> Void
    let onTapDelete: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(keywords, id: \.self) { keyword in
                RecentSearchRow(
                    keyword: keyword,
                    onTap: { onTap(keyword) },
                    onTapDelete: { onTapDelete(keyword) }
                )
            }
        }
    }
}

#Preview {
    RecentSearchList(keywords: ["1", "2"], onTap: { _ in }, onTapDelete: { _ in })
}
