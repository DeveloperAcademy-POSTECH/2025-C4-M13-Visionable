//
//  FfipKeyboardAdaptive.swift
//  FFIP-iOS
//
//  Created by mini on 7/21/25.
//

import Combine
import SwiftUI

struct FfipKeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    private let keyboardWillShow = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .compactMap { notification in
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        }
        .map { rect in
            rect.height
        }
    
    private let keyboardWillHide = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ in CGFloat(0) }
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(
                Publishers.Merge(keyboardWillShow, keyboardWillHide)
            ) { height in
                withAnimation {
                    self.keyboardHeight = height
                }
            }
    }
}

extension View {
    func ffipKeyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: FfipKeyboardAdaptive())
    }
}
