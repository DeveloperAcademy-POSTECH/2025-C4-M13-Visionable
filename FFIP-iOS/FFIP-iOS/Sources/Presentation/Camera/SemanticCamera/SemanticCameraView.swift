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
    
    @AppStorage(AppStorageKey.dontShowSemanticTipAgain) private var dontShowSemanticCameraTipAgain: Bool = false
    @State private var showTip = true
    @State private var showPopupTip = false
    
    @FocusState private var isFfipTextFieldFocused: Bool
    @State private var showFlash: Bool = false
    @State private var zoomGestureValue: CGFloat = 1.0
    @State private var animateCapture: Bool = false
    
    @State private var capturedImageRect: CGRect = .zero
    @State private var capturedImageStackPosition: CGPoint = .zero
    
    @State private var imageToAnimate: UIImage?
    
    @Query(sort: \SemanticCameraCapturedImage.createdAt, order: .reverse)
    private var capturedImages: [SemanticCameraCapturedImage]
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    GeometryReader { _ in
                        FrameView(image: mediator.frame)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear
                                        .onAppear {
                                            DispatchQueue.main.async {
                                                capturedImageRect = proxy.frame(in: .global)
                                            }
                                        }
                                }
                            )
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        handleZoomGestureChanged(value)
                                    }
                                    .onEnded { _ in
                                        zoomGestureValue = 1.0
                                    }
                            )
                            .onTapGesture(count: 2) {
                                captureFrameAndSave()
                            }
                    }
                }
            }
            
            VStack(spacing: 0) {
                FfipCameraHeaderBar(
                    zoomFactor: mediator.zoomFactor,
                    onZoom: { Task { await handleZoomButtonTapped() } },
                    isTorchOn: mediator.isTorchOn,
                    onToggleTorch: { Task { await mediator.toggleTorch() } },
                    onInfo: { showPopupTip = true },
                    onClose: {
                        Task {
                            await mediator.stop()
                            coordinator.pop()
                            deleteAllCapturedImages()
                        }
                    }
                )
                Spacer()
            }
            
            Color.black.opacity(isFfipTextFieldFocused ? 0.4 : 0)
                .onTapGesture {
                    isFfipTextFieldFocused = false
                }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    CapturedImageStackView(capturedImages: Array(capturedImages.prefix(5)))
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear {
                                        DispatchQueue.main.async {
                                            capturedImageStackPosition = proxy.frame(in: .global).center
                                        }
                                    }
                            }
                        )
                        .onTapGesture {
                            coordinator.push(.photoDetail)
                        }
                }
                .padding(.bottom, 12)
                .padding(.trailing, 20)
                
                FfipSearchTextField(
                    text: $mediator.visionModel.searchKeyword,
                    isFocused: true,
                    placeholder: mediator.visionModel.searchKeyword
                )
                .focused($isFfipTextFieldFocused)
                .padding(.bottom, isFfipTextFieldFocused ? 12 : 12 + safeAreaInset(.bottom))
                .padding(.horizontal, 20)
            }
            .ffipKeyboardAdaptive()
            
            if showTip && !dontShowSemanticCameraTipAgain {
                FfipCameraTipOverlay(
                    showTip: $showTip,
                    dontShowTipAgain: $dontShowSemanticCameraTipAgain,
                    ffipCameraTipType: .exact,
                    tipText1: String(localized: .semanticCameraTip1)
                        .asHighlight(
                            highlightedString: String(localized: .semanticCameraTipGreen1),
                            highlightColor: .ffipPointGreen1
                        ),
                    tipText2: String(localized: .semanticCameraTip2)
                        .asHighlight(
                            highlightedString: String(localized: .semanticCameraTipGreen2),
                            highlightColor: .ffipPointGreen1
                        ),
                    dontShowAgainText: String(localized: .dontShowAgain)
                )
            }
            
            if showPopupTip {
                FfipCameraPopupTipOverlay(showPopupTip: $showPopupTip, type: .semantic)
            }
            
            if showFlash {
                Color.white
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
            
            if animateCapture, let uiImage = imageToAnimate {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: capturedImageRect.width, height: capturedImageRect.height)
                    .position(x: capturedImageRect.midX, y: capturedImageRect.midY)
                    .clipped()
                    .modifier(
                        CaptureToStackAnimationModifier(
                            startRect: capturedImageRect,
                            endPoint: capturedImageStackPosition
                        )
                    )
                    .transition(.identity)
            }
        }
        .ignoresSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .task {
            await mediator.start()
        }
    }
}

private extension SemanticCameraView {
    func handleZoomGestureChanged(_ value: CGFloat) {
        let delta = value / zoomGestureValue
        zoomGestureValue = value
        let zoomFactor = mediator.zoomFactor
        Task {
            await mediator.zoom(to: zoomFactor * delta)
        }
    }
    
    func handleZoomButtonTapped() async {
        if mediator.zoomFactor >= 4.0 {
            await mediator.zoom(to: 1.0)
        } else if mediator.zoomFactor >= 2.0 {
            await mediator.zoom(to: 4.0)
        } else {
            await mediator.zoom(to: 2.0)
        }
    }
    
    func captureFrameAndSave() {
        guard let captureFrame = mediator.frame else { return }
        
        withAnimation(.easeIn(duration: 0.1)) {
            showFlash = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.3)) {
                showFlash = false
            }
            
            let ciImage = CIImage(cvImageBuffer: captureFrame)
            let context = CIContext()
            
            if let jpegData = context.jpegRepresentation(of: ciImage, colorSpace: CGColorSpaceCreateDeviceRGB()),
               let uiImage = UIImage(data: jpegData) {
                imageToAnimate = uiImage
                animateCapture = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    let capturedImage = SemanticCameraCapturedImage(imageData: jpegData)
                    let capturedImageId = capturedImage.id
                    modelContext.insert(capturedImage)

                    Task.detached(priority: .background) {
                        await analyzeAndUpdateCapturedImage(capturedImageId, buffer: captureFrame)
                    }
                    animateCapture = false
                }
            }
        }
    }
    
    @MainActor
    func analyzeAndUpdateCapturedImage(_ id: UUID, buffer: CVImageBuffer) async {
        guard let result = await mediator.analyzeCapturedImage(buffer) else {
            print("❌ 분석 실패")
            return
        }
        guard let targetImage = capturedImages.first(where: { $0.id == id }) else { return }
        
        let filteredRecognizedTexts = result.recognizedTexts.filter { observation in
            observation.transcript == result.keyword && result.similarity >= 0.5
        }
        targetImage.similarKeyword = result.keyword
        targetImage.similarity = result.similarity
        targetImage.recognizedTexts = filteredRecognizedTexts

        do {
            try modelContext.save()
        } catch {
            print("❌ 분석 후 저장 실패: \(error)")
        }
    }
    
    func deleteAllCapturedImages() {
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
