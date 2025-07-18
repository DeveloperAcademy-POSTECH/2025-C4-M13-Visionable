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
                        .onTapGesture(count: 2, perform: {
                            toggleCameraPauseAndShowLock()
                        })

                    ForEach(mediator.matchedObservations, id: \.self) { observation in
                        FfipBoundingBox(observation: observation)
                    }
                }
                .frame(width: screenHeight * 3 / 4, height: screenHeight)
                .clipped()
            }
            .ignoresSafeArea(.all)
            .frame(width: screenWidth, height: screenHeight)

            CameraLockIcon(
                isPaused: mediator.isCameraPaused,
                show: showLockIcon
            )

            VStack {
                HStack(alignment: .center) {
                    ZoomButton(
                        zoomFactor: mediator.zoomFactor,
                        action: {
                            Task {
                                await handleZoomButtonTapped()
                            }
                        }
                    )

                    Spacer()

                    TorchButton(
                        isTorchOn: mediator.isTorchOn,
                        action: {
                            Task {
                                await mediator.toggleTorch()
                            }
                        }
                    )

                    Spacer()

                    CloseButton {
                        Task {
                            await mediator.stop()
                            coordinator.pop()
                        }
                    }
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .padding(.top, safeAreaInset(.top))
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

    // TODO: Hi-Fi 디자인 이후 수정
    private struct TorchButton: View {
        let isTorchOn: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: isTorchOn ? "bolt.fill" : "bolt.slash")
                    .foregroundColor(isTorchOn ? .yellow : .white)
                    .font(.system(size: 16))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(.black.opacity(0.8))
                    )
            }
            .frame(maxWidth: 80)
        }
    }

    // TODO: Hi-Fi 디자인 이후 수정
    private struct ZoomButton: View {
        let zoomFactor: CGFloat
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(String(format: "%.1fx", zoomFactor / 2))
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.black.opacity(0.8))
                    )
            }
            .frame(maxWidth: 80)
        }
    }

    // TODO: Hi-Fi 디자인 이후 수정
    private struct CloseButton: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(.black.opacity(0.8))
                    )
            }
            .frame(maxWidth: 80)
        }
    }

    private struct CameraLockIcon: View {
        let isPaused: Bool
        let show: Bool

        var body: some View {
            Image(systemName: isPaused ? "lock.fill" : "lock.open.fill")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
                .padding(16)
                .background(
                    Circle()
                        .fill(.black.opacity(0.4))
                )
                .opacity(show ? 1 : 0)
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
