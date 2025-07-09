//
//  CameraView.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

struct CameraView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Bindable var cameraModel: CameraModel
    
    var body: some View {
        VStack {
            FrameView(image: cameraModel.frame)
        }
        .task {
            await cameraModel.start()
        }
    }
}

#Preview {
    CameraView(cameraModel: CameraModel())
}
