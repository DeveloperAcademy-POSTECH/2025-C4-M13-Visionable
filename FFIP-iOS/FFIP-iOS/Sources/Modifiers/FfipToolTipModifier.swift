//
//  FfipToolTipModifier.swift
//  FFIP-iOS
//
//  Created by mini on 7/16/25.
//

import SwiftUI

struct FfipToolTipModifier: ViewModifier {
    let message: String
    let duration: TimeInterval
    let position: FfipToolTipPosition
    let spacing: CGFloat
    
    @State private var isVisible: Bool = false
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        isVisible = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation(.easeInOut) {
                            isVisible = false
                        }
                    }
                }
            
            if isVisible {
                FfipToolTip(message: message, position: position)
                    .offset(offsetValue)
            }
        }
    }
    
    private var offsetValue: CGSize {
        switch position {
        case .top: return CGSize(width: 0, height: -spacing)
        case .bottom: return CGSize(width: 0, height: spacing)
        case .leading: return CGSize(width: -spacing, height: 0)
        case .trailing: return CGSize(width: spacing, height: 0)
        }
    }
}

extension View {
    func ffipToolTip(
        message: String,
        duration: TimeInterval = 2.0,
        position: FfipToolTipPosition,
        spacing: CGFloat
    ) -> some View {
        modifier(
            FfipToolTipModifier(
                message: message,
                duration: duration,
                position: position,
                spacing: spacing
            )
        )
    }
}
