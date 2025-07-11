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
    
    @State private var frame: CVImageBuffer?
    @State private var isAnalyzing = false
    
    var body: some View {
        ZStack {
            FrameView(image: frame)
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
            
            guard let imageBufferStream = cameraModel.imageBufferStream else { return }
            for await imageBuffer in imageBufferStream {
                guard !isAnalyzing else { continue }
                
                isAnalyzing = true
                frame = imageBuffer
                
                Task {
                    // TODO: await 이미지 분석 호출
                    
                    defer { isAnalyzing = false}
                }
            }
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
