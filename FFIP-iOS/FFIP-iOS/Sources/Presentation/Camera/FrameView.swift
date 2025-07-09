//
//  FrameView.swift
//  FFIP-iOS
//
//  Created by SeanCho on 7/9/25.
//

import SwiftUI

struct FrameView: UIViewRepresentable {
    let image: Any?
    var gravity = CALayerContentsGravity.resizeAspectFill

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.layer.contentsGravity = gravity
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.layer.contents = image
    }
}
