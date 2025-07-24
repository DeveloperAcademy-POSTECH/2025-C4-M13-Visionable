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
    private let placeholder: String
    private let onVoiceSearch: (() -> Void)?
    private let onSubmit: (() -> Void)?
    private let onEmptySubmit: (() -> Void)?
    private let withVoiceSearch: Bool

    public init(
        text: Binding<String>,
        isFocused: Bool,
        placeholder: String,
        onVoiceSearch: (() -> Void)? = nil,
        onSubmit: (() -> Void)? = nil,
        onEmptySubmit: (() -> Void)? = nil,
        withVoiceSearch: Bool = true
    ) {
        self._text = text
        self.isFocused = isFocused
        self.placeholder = placeholder
        self.onVoiceSearch = onVoiceSearch
        self.onSubmit = onSubmit
        self.onEmptySubmit = onEmptySubmit
        self.withVoiceSearch = withVoiceSearch
    }

    private var isTextEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(spacing: 4) {
            HStack(spacing: 12) {
                FfipUIKitTextField(
                    text: $text,
                    placeholder: placeholder,
                    isFirstResponder: isFocused
                )
                .foregroundStyle(.ffipGrayscale1)
                .font(.bodyMedium16)
                .padding(.vertical, 18)
                .padding(.leading, 20)
                .submitLabel(.search)
                .onSubmit {
                    isTextEmpty ? onEmptySubmit?() : onSubmit?()
                }
                .frame(height: 52)
                
                if isFocused && !isTextEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(.icnXButton)
                    }
                    .padding(.trailing, 20)
                }
            }
            .background(.ffipGrayscale5)
            .cornerRadius(50)

            if !isFocused && withVoiceSearch {
                Button {
                    onVoiceSearch?()
                } label: {
                    Image(.icnSettingsVoice)
                        .tint(.ffipGrayscale1)
                        .frame(width: 55, height: 55)
                        .background(Circle().fill(.ffipGrayscale5))
                }
            }
        }
    }
}

// #Preview {
//    FfipSearchTextField(
//        text: .constant("dd"),
//        isFocused: true,
//        placeholder: "어쩌구저쩌구 플레이스홀더"
//    )
// }
