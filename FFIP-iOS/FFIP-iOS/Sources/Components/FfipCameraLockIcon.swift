//
//  FfipCameraLockIcon.swift
//  FFIP-iOS
//
//  Created by SeanCho on 7/18/25.
//

import SwiftUI

struct FfipCameraLockIcon: View {
    let isPaused: Bool
    let show: Bool

    var body: some View {
        Image(systemName: isPaused ? "lock.fill" : "lock.open.fill")
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .bold))
            .padding(16)
            .background(
                Circle()
                    .fill(.black.opacity(0.4))
            )
            .opacity(show ? 1 : 0)
    }
}
