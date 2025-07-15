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
    /// 상위 뷰의 ignoreSafeArea 등으로 인해 Safe Area가 사라졌을 때, 사용할 수 있는 Safe Area의 Inset
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
