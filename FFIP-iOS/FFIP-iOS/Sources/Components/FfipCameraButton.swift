//
//  FfipCloseButton.swift
//  FFIP-iOS
//
//  Created by SeanCho on 7/21/25.
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

struct FfipInfoButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(.btnCameraInfo)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
        }
        .frame(maxWidth: 50)
    }
}
