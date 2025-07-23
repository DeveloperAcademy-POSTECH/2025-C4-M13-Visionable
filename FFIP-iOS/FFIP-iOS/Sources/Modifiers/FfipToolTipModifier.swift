//
//  FfipToolTipModifier.swift
//  FFIP-iOS
//
//  Created by mini on 7/16/25.
//

import SwiftUI

struct FfipToolTipModifier: ViewModifier {
    @Binding var isToolTipVisible: Bool
    let message: String
    let duration: TimeInterval
    let position: FfipToolTipPosition
    let spacing: CGFloat
        
    func body(content: Content) -> some View {
        ZStack {
            switch position {
            case .top:
                VStack(spacing: 0) {
                    FfipToolTip(message: message, position: position)
                        .padding(.bottom, spacing)
                        .scaleEffect(isToolTipVisible ? 1 : 0.2, anchor: .bottom)
                        .opacity(isToolTipVisible ? 1 : 0)
                    content
                }
            case .bottom:
                VStack(spacing: 0) {
                    content
                    FfipToolTip(message: message, position: position)
                        .padding(.top, spacing)
                        .scaleEffect(isToolTipVisible ? 1 : 0.2, anchor: .top)
                        .opacity(isToolTipVisible ? 1 : 0)
                }
                
            case .leading:
                HStack(spacing: 0) {
                    FfipToolTip(message: message, position: position)
                        .padding(.trailing, spacing)
                        .scaleEffect(isToolTipVisible ? 1 : 0.2, anchor: .trailing)
                        .opacity(isToolTipVisible ? 1 : 0)
                    
                    content
                }
            case .trailing:
                HStack(spacing: 0) {
                    content
                    FfipToolTip(message: message, position: position)
                        .padding(.leading, spacing)
                        .scaleEffect(isToolTipVisible ? 1 : 0.2, anchor: .leading)
                        .opacity(isToolTipVisible ? 1 : 0)
                }
            }
        }
        .onChange(of: isToolTipVisible) { _, isVisible in
            if isVisible {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation(.easeInOut) {
                        isToolTipVisible = false
                    }
                }
            }
        }

//        .onTapGesture {
//            guard !isToolTipVisible else { return }
//            withAnimation(.easeInOut) {
//                isToolTipVisible = true
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
//                guard isToolTipVisible else { return }
//                withAnimation(.easeInOut) {
//                    isToolTipVisible = false
//                }
//            }
//        }
    }
}

extension View {
    func ffipToolTip(
        isToolTipVisible: Binding<Bool>,
        message: String,
        duration: TimeInterval = 2.0,
        position: FfipToolTipPosition,
        spacing: CGFloat,
    ) -> some View {
        modifier(
            FfipToolTipModifier(
                isToolTipVisible: isToolTipVisible,
                message: message,
                duration: duration,
                position: position,
                spacing: spacing
            )
        )
    }
}
