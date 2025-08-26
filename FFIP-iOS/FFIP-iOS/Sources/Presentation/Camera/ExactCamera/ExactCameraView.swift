//
//  CameraView.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI
import Vision

struct ExactCameraView: View {
    @Environment(AppCoordinator.self) private var coordinator
    
    @Bindable var cameraModel: CameraModel
    @Bindable var visionModel: VisionModel
    @Bindable var searchModel: SearchModel

    @State private var zoomGestureValue: CGFloat = 1.0
    @State private var showLockIcon: Bool = false
    @State private var showLockTask: Task<Void, Never>?

    @AppStorage(AppStorageKey.dontShowExactTipAgain) private
        var dontShowExactCameraTipAgain: Bool = false
    @State private var showTip = true
    @State private var showPopupTip = false

    @State var searchText: String
    @State private var lastSearchText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    FrameView(image: cameraModel.frame)
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
                                toggleCameraPauseAndShowLock()
                            }
                        )

                    ForEach(visionModel.matchedObservations, id: \.self) { observation in
                        FfipBoundingBox(observation: observation)
                    }
                }
                .frame(width: screenHeight * 9 / 16, height: screenHeight)
                .clipped()
            }
            .ignoresSafeArea(.all)
            .frame(width: screenWidth, height: screenHeight)

            VStack(spacing: 0) {
                FfipCameraHeaderBar(
                    zoomFactor: cameraModel.zoomFactor,
                    onZoom: { Task { await cameraModel.handleZoomButtonTapped() } },
                    isTorchOn: cameraModel.isTorchOn,
                    onToggleTorch: { Task { await cameraModel.toggleTorch() } },
                    onInfo: { showPopupTip = true },
                    onClose: {
                        Task {
                            await cameraModel.stop()
                            coordinator.popToRoot()
                        }
                    }
                )
                Spacer()
            }

            FfipCameraLockIcon(
                isPaused: cameraModel.isCameraPaused,
                show: showLockIcon
            )

            Color.black.opacity(isTextFieldFocused ? 0.4 : 0)
                .onTapGesture {
                    isTextFieldFocused = false
                }

            VStack {
                Spacer()
                    .showFfipToastMessage(
                        toastType: .warning,
                        toastTitle: "렌즈의 지문을 닦거나 천천히 움직여 주세요.",
                        isToastVisible: $visionModel.isShowSmudgeToast
                    )

                FfipSearchTextField(
                    text: $searchText,
                    isFocused: isTextFieldFocused,
                    placeholder: String(
                        localized: .searchPlaceholder
                    ),
                    onSubmit: {
                        lastSearchText = searchText
                        visionModel.changeSearchKeyword(keyword: searchText)
                        searchModel.addRecentSearchKeyword(searchText)
                    },
                    withVoiceSearch: false
                )
                .focused($isTextFieldFocused)
                .padding(.horizontal, 20)
                .padding(
                    .bottom,
                    isTextFieldFocused ? 12 : 12 + safeAreaInset(.bottom)
                )
            }
            .ffipKeyboardAdaptive()

            if showTip && !dontShowExactCameraTipAgain {
                FfipCameraTipOverlay(
                    showTip: $showTip,
                    dontShowTipAgain: $dontShowExactCameraTipAgain,
                    ffipCameraTipType: .exact,
                    tipText1: String(localized: .exactCameraTip1)
                        .asHighlight(
                            highlightedString: String(
                                localized: .exactCameraTipGreen1
                            ),
                            highlightColor: .ffipPointGreen1
                        ),
                    tipText2: String(localized: .exactCameraTip2)
                        .asHighlight(
                            highlightedString: String(
                                localized: .exactCameraTipGreen2
                            ),
                            highlightColor: .ffipPointGreen1
                        ),
                    dontShowAgainText: String(localized: .dontShowAgain)
                )
            }
            
            if showPopupTip {
                FfipCameraPopupTipOverlay(showPopupTip: $showPopupTip, type: .exact)
            }
        }
        .ignoresSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .onChange(of: visionModel.matchedObservations) { _, newObservations in
            if !newObservations.isEmpty { triggerHapticFeedback() }
        }
        .task {
            self.lastSearchText = searchText
            await cameraModel.start()
            await visionModel.prepare()

            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    await cameraModel.distributeDisplayFrame()
                }
                
                group.addTask {
                    await visionModel.distributeAnalyzeFrame(cameraModel.analysisFramesStream)
                }
            }
        }
        .onChange(of: isTextFieldFocused) {
            Task {
                try? await Task.sleep(for: .milliseconds(100))
                searchText = lastSearchText
            }
        }
        .animation(.default, value: isTextFieldFocused)
    }
}

private extension ExactCameraView {
    func handleZoomGestureChanged(_ value: CGFloat) {
        let delta = value / zoomGestureValue
        zoomGestureValue = value
        Task {
            await cameraModel.zoom(to: cameraModel.zoomFactor * delta)
        }
    }

    func toggleCameraPauseAndShowLock() {
        showLockTask?.cancel()
        withAnimation { showLockIcon = true }
        if cameraModel.isCameraPaused {
            cameraModel.resumeCamera()
            showLockTask = Task {
                try? await Task.sleep(for: .seconds(0.8))
                if Task.isCancelled { return }
                withAnimation {
                    showLockIcon = false
                }
            }
        } else {
            cameraModel.pauseCamera()
        }
    }
}

// #Preview {
//    CameraView(mediator: mediator())
// }
