//
//  FfipTextField.swift
//  FFIP-iOS
//
//  Created by Jamin on 7/11/25.
//

import SwiftUI

struct FfipSearchTextField: View {
    @Binding var text: String

    private let isFocused: Bool
    private let placeholder: LocalizedStringResource
    private let onVoiceSearch: (() -> Void)?
    private let onSubmit: (() -> Void)?
    private let withVoiceSearch: Bool

    public init(
        text: Binding<String>,
        isFocused: Bool = false,
        placeholder: LocalizedStringResource,
        onVoiceSearch: (() -> Void)? = nil,
        onSubmit: (() -> Void)? = nil,
        withVoiceSearch: Bool = true
    ) {
        self._text = text
        self.isFocused = isFocused
        self.placeholder = placeholder
        self.onVoiceSearch = onVoiceSearch
        self.onSubmit = onSubmit
        self.withVoiceSearch = withVoiceSearch
    }

    private var isTextEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(spacing: 4) {
            ZStack(alignment: .trailing) {
                FfipUIKitTextField(
                    text: $text,
                    placeholder: String(localized: placeholder),
                    isFirstResponder: isFocused,
                    onSubmit: onSubmit
                )
                .foregroundStyle(.ffipGrayscale1)
                .font(.bodyMedium16)
                .padding(.vertical, 18)
                .submitLabel(.search)
                .frame(height: 55)
                .frame(minWidth: 0, maxWidth: .infinity)
                .accessibilityLabel("탐색창")
                .accessibilityHint("찾고 싶은 탐색어를 입력하세요. 입력을 완료하면 카메라 뷰를 켜서 탐색을 시작합니다.")
                Button {
                    text = ""
                } label: {
                    Image(.icnXButton)
                }
                .padding(.trailing, 20)
                .opacity(isFocused && !isTextEmpty ? 1 : 0)
            }
            .background(.ffipGrayscale5)
            .cornerRadius(50)

            if withVoiceSearch {
                Button {
                    onVoiceSearch?()
                } label: {
                    Image(.icnSettingsVoice)
                        .tint(.ffipGrayscale1)
                        .frame(width: 55, height: 55)
                        .background(Circle().fill(.ffipGrayscale5))
                }
                .accessibilityLabel("음성 입력")
                .accessibilityHint("음성으로 탐색어를 입력할 수 있습니다. 탭하면 음성 인식이 시작됩니다.")
            }
        }
    }
}

// #Preview {
//    @Previewable @State var text: String = ""
//    FfipSearchTextField(
//        text: $text,
//        isFocused: true,
//        placeholder: "어쩌구저쩌구 플레이스홀더",
//        withVoiceSearch: false
//    )
//    .padding(.horizontal, 20)
// }
