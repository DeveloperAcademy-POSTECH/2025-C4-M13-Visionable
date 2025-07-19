//
//  SearchTypeSelectionView.swift
//  FFIP-iOS
//
//  Created by Jamin on 7/18/25.
//

import SwiftUI

struct SearchTypeRow: View {
    private let title: String
    private let tagImage: ImageResource?
    private let isSelected: Bool
    private let onTap: () -> Void
    
    init(
        title: String,
        tagImage: ImageResource? = nil,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.tagImage = tagImage
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Text(title)
                if let tagImage {
                    Image(tagImage)
                }
            }
            
            Spacer()
            
            Image(isSelected ? .icnCheckEnabled : .icnCheckDisabled)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct SearchTypeSelectionView: View {
    @Binding var selectedType: SearchType
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 24) {
                ForEach(SearchType.allCases) { type in
                    SearchTypeRow(
                        title: String(localized: type.title),
                        tagImage: type.tagIcon,
                        isSelected: selectedType == type,
                        onTap: {
                            selectedType = type
                        }
                    )
                }
            }
        }
    }
}

// #Preview {
//    SearchTypeSelectionView(selectedType: .constant(.keyword))
// }
