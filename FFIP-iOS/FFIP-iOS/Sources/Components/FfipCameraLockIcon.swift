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
        Image(isPaused ? "img_lock" : "img_lock_open")
            .frame(width: 60, height: 60)
            .opacity(show ? 1 : 0)
    }
}
