//
//  SearchTypeSelectionView.swift
//  FFIP-iOS
//
//  Created by Jamin on 7/18/25.
//

import SwiftUI

struct SearchTypeSelectionView: View {
    @Binding var selectedType: SearchType
    let dismissAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text(.selectSearchMode)
                .font(.titleBold20)
                .foregroundStyle(.ffipGrayscale1)
                .accessibilityAddTraits(.isHeader)
                .accessibilitySortPriority(1)
            
            VStack(spacing: 24) {
                ForEach(SearchType.allCases) { type in
                    SearchTypeRow(
                        title: String(localized: type.title),
                        tagImage: type.tagIcon,
                        isSelected: selectedType == type,
                        onTap: {
                            selectedType = type
                            dismissAction()
                        }
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(selectedType == .exact ? "지정 탐색" : "연관 탐색")
                    .accessibilityValue(selectedType == .exact ? "탐색창에 입력하는 텍스트와 정확히 일치하는 항목만 찾아줍니다." : "탐색창에 입력하는 텍스트와 연관된 모든 항목을 찾아줍니다.")
                    .accessibilityHint("눌러서 탐색모드를 변경할 수 있습니다.")
                    .accessibilityAddTraits(.isButton)
                }
            }
        }
    }
}

private struct SearchTypeRow: View {
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

// #Preview {
//    SearchTypeSelectionView(selectedType: .constant(.keyword))
// }
