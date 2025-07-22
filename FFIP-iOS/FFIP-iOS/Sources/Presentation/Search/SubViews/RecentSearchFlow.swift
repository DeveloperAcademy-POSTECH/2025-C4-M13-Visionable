//
//  RecentSearchFlow.swift
//  FFIP-iOS
//
//  Created by Jamin on 7/20/25.
//

import SwiftUI

struct RecentSearchFlow: View {
    let keywords: [String]
    let onTap: (String) -> Void
    let onTapDelete: (String) -> Void
    
    var body: some View {
        HFlowLayout(spacing: 6, lineSpacing: 6) {
            ForEach(keywords, id: \.self) { keyword in
                FfipRecentSearchCapsule(
                    keyword: keyword,
                    onTap: { onTap(keyword) },
                    onTapDelete: { onTapDelete(keyword) }
                )
            }
        }
    }
}

// #Preview {
//    RecentSearchFlow(keywords: ["1dd2dddddddddddddddddddd2dddddddddddddddddddddddddd", "2dddddddd", "2dddddddddddddddddddd2dddddddddddddddddddd2dddddddddddddddddddd"], onTap: { _ in }, onTapDelete: { _ in })
// }
