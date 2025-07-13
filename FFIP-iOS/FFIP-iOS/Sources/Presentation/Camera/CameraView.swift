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

    @State var zoomGestureValue: CGFloat = 1.0

    var body: some View {
        ZStack {
            FrameView(image: cameraModel.frameToDisplay)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            handleZoomGestureChanged(value)
                        }
                        .onEnded { _ in
                            zoomGestureValue = 1.0
                        }
                )
            // TODO: - 박스 영역 디자인 완료 후 수정
            ForEach(cameraModel.recognizedTextObservations, id: \.self) { observation in
                Box(observation: observation)
                    .stroke(.red, lineWidth: 1)
            }
        }
        .task {
            await cameraModel.start()

            Task { await cameraModel.distributeDisplayFrames() }
            Task { await cameraModel.distributeAnalyzeFrames() }
        }
    }

    private func handleZoomGestureChanged(_ value: CGFloat) {
        let delta = value / zoomGestureValue
        zoomGestureValue = value
        let zoomFactor = cameraModel.zoomFactor
        Task {
            await cameraModel.zoom(to: zoomFactor * delta)
        }
    }
}

// #Preview {
//    CameraView(cameraModel: CameraModel())
// }
