//
//  FfipCaptureToStackAnimationModifier.swift
//  FFIP-iOS
//
//  Created by mini on 7/22/25.
//

import SwiftUI

struct CaptureToStackAnimationModifier: ViewModifier {
    let startRect: CGRect
    let endPoint: CGPoint
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var size: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .frame(width: size.width, height: size.height)
            .scaleEffect(scale)
            .offset(offset)
            .onAppear {
                size = startRect.size
                withAnimation(.easeInOut(duration: 0.6)) {
                    size = CGSize(width: 88, height: 117)
                    scale = 1.0
                    offset = CGSize(
                        width: endPoint.x - startRect.midX,
                        height: endPoint.y - startRect.midY
                    )
                }
            }
    }
}
