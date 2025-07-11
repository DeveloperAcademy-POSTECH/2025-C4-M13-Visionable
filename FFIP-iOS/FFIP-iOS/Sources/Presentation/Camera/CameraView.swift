//
//  CameraView.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI
import Vision

struct CameraView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Bindable var cameraModel: CameraModel
    
    var body: some View {
        ZStack {
            FrameView(image: cameraModel.frame)
            ForEach(cameraModel.recognizedTextObservations, id: \.self) { observation in
                Box(observation: observation)
                    .stroke(.red, lineWidth: 1)
                    .overlay {
                        Text(observation.topCandidates(1).first?.string ?? "기본")
                    }
            }
        }
        .task {
            await cameraModel.start()
        }
        .onChange(of: cameraModel.frame) {
            print("⭐️", cameraModel.recognizedTextObservations)
            cameraModel.recognizedTextObservations.forEach {
                print("❌", $0.topCandidates(1).first?.string)
            }
        }
    }
}

#Preview {
    CameraView(cameraModel: CameraModel())
}
