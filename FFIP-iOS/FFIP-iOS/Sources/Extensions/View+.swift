//
//  View+.swift
//  FFIP-iOS
//
//  Created by mini on 7/12/25.
//

import SwiftUI

extension View {
    /// 햅틱 발생시키는 UIKit Extension Method
    func triggerHapticFeedback() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

extension View {
    func safeAreaInset(_ edge: Edge.Set) -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return 0
        }
        let inset = window.safeAreaInsets
        switch edge {
        case .top: return inset.top
        case .bottom: return inset.bottom
        case .leading: return inset.left
        case .trailing: return inset.right
        default: return 0
        }
    }
}
