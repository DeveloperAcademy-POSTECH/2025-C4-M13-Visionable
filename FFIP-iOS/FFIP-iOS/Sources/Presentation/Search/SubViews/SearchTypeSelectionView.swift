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
        VStack(alignment: .leading, spacing: 38) {
            Text(.selectSearchMode)
                .font(.titleBold20)
                .foregroundStyle(.ffipGrayscale1)
                .accessibilityAddTraits(.isHeader)
                .accessibilitySortPriority(1)

            VStack(spacing: 26) {
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
                    .accessibilityLabel(
                        String(
                            localized: selectedType == .exact
                                ? .VoiceOverLocalizable.exactSearch
                                : .VoiceOverLocalizable.semanticSearch
                        )
                    )
                    .accessibilityValue(
                        selectedType == .exact
                        ? .VoiceOverLocalizable.exactSelectValue
                            : .VoiceOverLocalizable.semanticSelectValue
                    )
                    .accessibilityHint(
                        String(
                            localized: .VoiceOverLocalizable.changeSearchMode
                        )
                    )
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
                    .font(.bodyMedium16)
                    .foregroundStyle(.ffipGrayscale2)
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
//     SearchTypeSelectionView(selectedType: .constant(.exact), dismissAction: {})
// }
