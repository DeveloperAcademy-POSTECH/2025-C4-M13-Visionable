//
//  FfipTextField.swift
//  FFIP-iOS
//
//  Created by Jamin on 7/11/25.
//

import SwiftUI

struct FfipTextField: View {
    var placeholder: String
    @Binding var text: String
    
    var onVoiceSearch: () -> Void
    var onSubmit: () -> Void
    var onEmptySubmit: () -> Void
    
    private var isTextEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .padding(.vertical, 16)
                .submitLabel(.search)
                .onSubmit {
                    if isTextEmpty {
                        onEmptySubmit()
                    } else {
                        onSubmit()
                    }
                }
            
            Button {
                if isTextEmpty {
                    onVoiceSearch()
                } else {
                    text = ""
                }
            } label: {
                Image(systemName: isTextEmpty ? "mic.fill" : "xmark.circle.fill")
            }
            .tint(.black)
        }
        .padding(.horizontal, 20)
        .background(.gray.opacity(0.2))
    }
}

//#Preview {
//    @Previewable @State var text = "검색어"
//    FfipTextField(placeholder: "placeholder", text: $text, onVoiceSearch: {})
//}
