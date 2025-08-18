//
//  FfipCloseButton.swift
//  FFIP-iOS
//
//  Created by Sean Cho on 8/15/25.
//

import SwiftUI

struct FfipCloseButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(.btnCameraClose)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
        }
        .frame(maxWidth: 50)
    }
}
