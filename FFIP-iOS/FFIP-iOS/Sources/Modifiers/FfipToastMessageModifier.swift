//
//  FfipToastMessageModifier.swift
//  FFIP-iOS
//
//  Created by mini on 7/15/25.
//

import SwiftUI

struct FfipToastMessageModifier: ViewModifier {
    @Binding var isToastVisible: Bool
    let toastType: FfipToastType
    let toastTitle: String
    let bottomPadding: CGFloat
    let duration: TimeInterval
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isToastVisible {
                VStack {
                    Spacer()
                    FfipToastMessage(
                        toastType: toastType,
                        toastTitle: toastTitle
                    )
                    .frame(maxWidth: .infinity)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .padding(.bottom, bottomPadding)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation {
                            isToastVisible = false
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func showFfipToastMessage(
        toastType: FfipToastType,
        toastTitle: String,
        isToastVisible: Binding<Bool>,
        bottomPadding: CGFloat = 4.0,
        duration: TimeInterval = 2.0
    ) -> some View {
        self.modifier(
            FfipToastMessageModifier(
                isToastVisible: isToastVisible,
                toastType: toastType,
                toastTitle: toastTitle,
                bottomPadding: bottomPadding,
                duration: duration
            )
        )
    }
}
