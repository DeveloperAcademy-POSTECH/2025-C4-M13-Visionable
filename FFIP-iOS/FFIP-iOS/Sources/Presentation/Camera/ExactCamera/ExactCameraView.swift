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
    @Bindable var mediator: ExactCameraMediator

    @State private var zoomGestureValue: CGFloat = 1.0
    @State private var showLockIcon: Bool = false
    @State private var showLockTask: Task<Void, Never>?

    @AppStorage(AppStorageKey.dontShowExactTipAgain) private var dontShowExactCameraTipAgain: Bool = false
    @State private var showTip = true

    @State var searchText: String
    @State private var lastSearchText: String = ""
    @FocusState private var isTextFieldFocused: Bool

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
                                toggleCameraPauseAndShowLock()
                            }
                        )

                    ForEach(mediator.matchedObservations, id: \.self) { observation in
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
                    zoomFactor: mediator.zoomFactor,
                    onZoom: { Task { await handleZoomButtonTapped() } },
                    isTorchOn: mediator.isTorchOn,
                    onToggleTorch: { Task { await mediator.toggleTorch() } },
                    onInfo: {},
                    onClose: {
                        Task {
                            await mediator.stop()
                            coordinator.popToRoot()
                        }
                    }
                )
                Spacer()
            }

            FfipCameraLockIcon(
                isPaused: mediator.isCameraPaused,
                show: showLockIcon
            )

            Color.black.opacity(isTextFieldFocused ? 0.4 : 0)
                .onTapGesture {
                    isTextFieldFocused = false
                }

            VStack {
                Spacer()
                FfipSearchTextField(
                    text: $searchText,
                    isFocused: isTextFieldFocused,
                    placeholder: String(
                        localized: .searchPlaceholder
                    ),
                    onSubmit: {
                        lastSearchText = searchText
                        mediator.changeSearchKeyword(keyword: searchText)
                    },
                    withVoiceSearch: false
                )
                .focused($isTextFieldFocused)
                .padding(.horizontal, 20)
                .padding(.bottom, isTextFieldFocused ? 12 : 12 + safeAreaInset(.bottom))
            }
            .ffipKeyboardAdaptive()

            if showTip && !dontShowExactCameraTipAgain {
                FfipCameraTipOverlay(
                    showTip: $showTip,
                    dontShowTipAgain: $dontShowExactCameraTipAgain,
                    ffipCameraTipType: .exact,
                    tipText1: String(localized: .exactCameraTip1)
                        .asHighlight(
                            highlightedString: String(localized: .exactCameraTipGreen1),
                            highlightColor: .ffipPointGreen1
                        ),
                    tipText2: String(localized: .exactCameraTip2)
                        .asHighlight(
                            highlightedString: String(localized: .exactCameraTipGreen2),
                            highlightColor: .ffipPointGreen1
                        ),
                    dontShowAgainText: String(localized: .dontShowAgain)
                )
            }
        }
        .ignoresSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .onChange(of: mediator.matchedObservations) { _, newObservations in
            if !newObservations.isEmpty { triggerHapticFeedback() }
        }
        .task {
            self.lastSearchText = searchText
            await mediator.start()
        }
        .onChange(of: isTextFieldFocused) {
            Task {
                try? await Task.sleep(for: .milliseconds(100))
                searchText = lastSearchText
            }
        }
        .animation(.default, value: isTextFieldFocused)
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

    private func toggleCameraPauseAndShowLock() {
        if mediator.isCameraPaused {
            mediator.resumeCamera()
        } else {
            mediator.pauseCamera()
        }
        showLockTask?.cancel()
        withAnimation {
            showLockIcon = true
        }
        showLockTask = Task {
            try? await Task.sleep(
                for: .seconds(mediator.isCameraPaused ? 1 : 0.8)
            )
            if Task.isCancelled { return }
            withAnimation {
                showLockIcon = false
            }
        }
    }
}

// #Preview {
//    CameraView(mediator: mediator())
// }
