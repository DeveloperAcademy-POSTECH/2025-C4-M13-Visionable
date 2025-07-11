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
            // TODO: - 박스 영역 디자인 완료 후 수정
            ForEach(cameraModel.matchedObservations, id: \.self) { observation in
                Box(observation: observation)
                    .stroke(.red, lineWidth: 1)
            }
            
            TextField("찾을 단어 입력", text: $cameraModel.inputText)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
        }
        .task {
            await cameraModel.start()
            
            guard let imageBufferStream = cameraModel.imageBufferStream else { return }
            for await imageBuffer in imageBufferStream {
                guard !isAnalyzing else { continue }
                
                isAnalyzing = true
                frame = imageBuffer
                
                Task {
                    defer { isAnalyzing = false }
                    await cameraModel.processFrame(imageBuffer)
                }
            }
        }
    }
}

#Preview {
    CameraView(cameraModel: CameraModel())
}
