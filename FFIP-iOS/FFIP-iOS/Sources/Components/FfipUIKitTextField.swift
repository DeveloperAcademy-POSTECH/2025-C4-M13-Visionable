//
//  FfipUIKitTextField.swift
//  FFIP-iOS
//
//  Created by Jamin on 7/24/25.
//

import SwiftUI
import UIKit

struct FfipUIKitTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var isFirstResponder: Bool
    var onSubmit: (() -> Void)?
    var onEmptySubmit: (() -> Void)?
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.returnKeyType = .search
        textField.enablesReturnKeyAutomatically = true
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged), for: .editingChanged)
        
        textField.textColor = .ffipGrayscale1
        textField.font = .bodyMedium16
        textField.addPadding(left: 20, right: 52)
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.placeholder = placeholder
        if isFirstResponder && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: FfipUIKitTextField
        
        init(_ parent: FfipUIKitTextField) {
            self.parent = parent
        }
        
        @objc func textChanged(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            let trimmed = parent.text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                parent.onEmptySubmit?()
            } else {
                parent.onSubmit?()
            }
            return true
        }
    }
}
