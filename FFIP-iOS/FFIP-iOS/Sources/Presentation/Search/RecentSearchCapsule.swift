//
//  RecentSearchCapsule.swift
//  FFIP-iOS
//
//  Created by Jamin on 7/14/25.
//

import SwiftUI

struct RecentSearchCapsule: View {
    var keyword: String
    var onTap: () -> Void
    var onTapDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Text(keyword)
                .foregroundStyle(.black)
            
            Button(action: onTapDelete) {
                Image(systemName: "xmark")
            }
            .tint(.black)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 50)
                .fill(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
        )
        .onTapGesture {
            onTap()
        }
        
    }
}

#Preview {
    RecentSearchCapsule(keyword: "검색어", onTap: {}, onTapDelete: {})
}
