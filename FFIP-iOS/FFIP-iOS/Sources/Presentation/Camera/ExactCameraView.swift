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

    @AppStorage("dontShowExactTipAgain") private var dontShowTipAgain: Bool = false
    @State private var showTip = true

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

                    ForEach(mediator.matchedObservations, id: \.self) {
                        observation in
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

            FfipCameraLockIcon(
                isPaused: mediator.isCameraPaused,
                show: showLockIcon
            )

            if showTip && !dontShowTipAgain {
                FfipCameraTipOverlay(
                    showTip: $showTip,
                    dontShowTipAgain: $dontShowTipAgain,
                    tipText1: tipText1,
                    tipText2: tipText2,
                    dontShowAgainText: dontShowAgainText
                )
            }
        }
        .ignoresSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .onChange(of: mediator.matchedObservations) { _, newObservations in
            if !newObservations.isEmpty { triggerHapticFeedback() }
        }
        .task {
            await mediator.start()
        }
    }
    
    private var tipText1: AttributedString {
        var str = AttributedString(
            localized: .cameraTip1
        )
        str.font = .labelMedium16
        str.alignment = .center
        str.foregroundColor = .ffipGrayScaleDefault2
        if let first = str.range(of: String(localized: .cameraTipGreen1)) {
            str[first].foregroundColor = .ffipPointGreen1
        }
        return str
    }

    private var tipText2: AttributedString {
        var str = AttributedString(
            localized: .cameraTip2
        )
        str.font = .labelMedium16
        str.alignment = .center
        str.foregroundColor = .ffipGrayScaleDefault2
        if let first = str.range(of: String(localized: .cameraTipGreen2)) {
            str[first].foregroundColor = .ffipPointGreen1
        }
        return str
    }

    private var dontShowAgainText: AttributedString {
        var str = AttributedString(
            localized: .dontShowAgain
        )
        str.font = .labelMedium14
        str.underlineStyle = .single
        str.alignment = .center
        str.foregroundColor = .white.opacity(0.8)

        return str
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
