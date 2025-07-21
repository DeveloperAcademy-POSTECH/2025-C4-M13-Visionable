//
//  RelatedCameraView.swift
//  FFIP-iOS
//
//  Created by SeanCho on 7/18/25.
//

import SwiftData
import SwiftUI
import Vision

struct SemanticCameraView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.modelContext) private var modelContext
    @Bindable var mediator: SemanticCameraMediator
    
    @State private var showFlash: Bool = false
    @State private var zoomGestureValue: CGFloat = 1.0
    @State private var showLockIcon: Bool = false
    @State private var showLockTask: Task<Void, Never>?
    @State private var textField: String = "어쩔"
    
    @Query(sort: \SemanticCameraCapturedImage.createdAt, order: .reverse)
    private var capturedImages: [SemanticCameraCapturedImage]
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    FrameView(image: mediator.frame)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    handleZoomGestureChanged(value)
                                }
                                .onEnded { _ in
                                    zoomGestureValue = 1.0
                                }
                        )
                        .onTapGesture(
                            count: 2,
                            perform: {
                                captureFrameAndSave()
                            }
                        )
                    
                    ForEach(mediator.matchedObservations, id: \.self) { observation in
                        FfipBoundingBox(observation: observation)
                    }
                }
                .frame(width: screenHeight * 3 / 4, height: screenHeight)
                .clipped()
            }
            .ignoresSafeArea(.all)
            .frame(width: screenWidth, height: screenHeight)
            
            VStack(spacing: 0) {
                FfipCameraHeaderBar(
                    zoomFactor: mediator.zoomFactor,
                    onZoom: { Task { await handleZoomButtonTapped() } },
                    isTorchOn: mediator.isTorchOn,
                    onToggleTorch: { Task { await mediator.toggleTorch() } },
                    onInfo: {},
                    onClose: {
                        Task {
                            await mediator.stop()
                            coordinator.pop()
                        }
                    }
                )
                Spacer()
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    CapturedImageStackView(capturedImages: Array(capturedImages.prefix(5)))
                }
                .padding(.bottom, 12)
                .padding(.trailing, 20)
                
                FfipSearchTextField(
                    text: $textField,
                    isExistVoiceSeachButton: false,
                    placeholder: textField
                )
                .padding(.bottom, 12)
                .padding(.horizontal, 20)
            }
            .ffipKeyboardAdaptive()
            
            if showFlash {
                Color.white
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .ignoresSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            deleteAllCapturedImages()
        }
        .onChange(of: mediator.matchedObservations) { _, newObservations in
            if !newObservations.isEmpty { triggerHapticFeedback() }
        }
        .task {
            await mediator.start()
        }
    }
    
    private func handleZoomGestureChanged(_ value: CGFloat) {
        let delta = value / zoomGestureValue
        zoomGestureValue = value
        let zoomFactor = mediator.zoomFactor
        Task {
            await mediator.zoom(to: zoomFactor * delta)
        }
    }
    
    private func handleZoomButtonTapped() async {
        if mediator.zoomFactor >= 4.0 {
            await mediator.zoom(to: 1.0)
        } else if mediator.zoomFactor >= 2.0 {
            await mediator.zoom(to: 4.0)
        } else {
            await mediator.zoom(to: 2.0)
        }
    }
    
    private func captureFrameAndSave() {
        guard let captureFrame = mediator.frame else { return }
        
        withAnimation(.easeIn(duration: 0.1)) {
            showFlash = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.3)) {
                showFlash = false
                
                let ciImage = CIImage(cvImageBuffer: captureFrame)
                let context = CIContext()
                
                if let jpegData = context.jpegRepresentation(
                    of: ciImage,
                    colorSpace: CGColorSpaceCreateDeviceRGB()
                ) {
                    let capturedImage = SemanticCameraCapturedImage(imageData: jpegData)
                    modelContext.insert(capturedImage)
                }
            }
        }
        

    }
    
    private func deleteAllCapturedImages() {
        for image in capturedImages {
            modelContext.delete(image)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("failed to delete captured Images")
        }
    }
}
