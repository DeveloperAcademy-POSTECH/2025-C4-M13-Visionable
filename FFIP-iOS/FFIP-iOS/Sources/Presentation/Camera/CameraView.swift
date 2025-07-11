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
    
    @State private var frame: CVImageBuffer?
    
    var body: some View {
        VStack {
            FrameView(image: frame)
        }
        .task {
            await cameraModel.start()
            
            guard let imageBufferStream = cameraModel.imageBufferStream else { return }
            for await imageBuffer in imageBufferStream {
                frame = imageBuffer
                
                // TODO: 이미지 분석 호출
            }
        }
    }
}

#Preview {
    CameraView(cameraModel: CameraModel())
}
