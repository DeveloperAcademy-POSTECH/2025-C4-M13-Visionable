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
            switch position {
            case .top:
                VStack(spacing: 0) {
                    FfipToolTip(message: message, position: position)
                        .padding(.bottom, spacing)
                        .scaleEffect(isVisible ? 1 : 0.2, anchor: .bottom)
                        .opacity(isVisible ? 1 : 0)
                    content
                }
            case .bottom:
                VStack(spacing: 0) {
                    content
                    FfipToolTip(message: message, position: position)
                        .padding(.top, spacing)
                        .scaleEffect(isVisible ? 1 : 0.2, anchor: .top)
                        .opacity(isVisible ? 1 : 0)
                }
                
            case .leading:
                HStack(spacing: 0) {
                    FfipToolTip(message: message, position: position)
                        .padding(.trailing, spacing)
                        .scaleEffect(isVisible ? 1 : 0.2, anchor: .trailing)
                        .opacity(isVisible ? 1 : 0)
                    
                    content
                }
            case .trailing:
                HStack(spacing: 0) {
                    content
                    FfipToolTip(message: message, position: position)
                        .padding(.leading, spacing)
                        .scaleEffect(isVisible ? 1 : 0.2, anchor: .leading)
                        .opacity(isVisible ? 1 : 0)
                }
            }
        }
        .onTapGesture {
            guard !isVisible else { return }
            withAnimation(.easeInOut) {
                isVisible = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                guard isVisible else { return }
                withAnimation(.easeInOut) {
                    isVisible = false
                }
            }
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
