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

    @State private var zoomGestureValue: CGFloat = 1.0
    @State private var showLockIcon: Bool = false
    @State private var showLockTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            VStack {
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
                        .onTapGesture(count: 2, perform: {
                            toggleCameraPauseAndShowLock()
                        })

                    // TODO: - 박스 영역 디자인 완료 후 수정
                    ForEach(cameraModel.matchedObservations, id: \.self) { observation in
                        Box(observation: observation)
                            .stroke(.red, lineWidth: 1)
                    }
                }
                .frame(width: screenHeight * 3 / 4, height: screenHeight)
                .clipped()
            }
            .ignoresSafeArea(.all)
            .frame(width: screenWidth, height: screenHeight)

            CameraLockIcon(
                isPaused: cameraModel.isCameraPaused,
                show: showLockIcon
            )

            VStack {
                HStack(alignment: .center) {
                    ZoomButton(
                        zoomFactor: cameraModel.zoomFactor,
                        action: {
                            Task {
                                await handleZoomButtonTapped()
                            }
                        }
                    )

                    Spacer()

                    TorchButton(
                        isTorchOn: cameraModel.isTorchOn,
                        action: {
                            Task {
                                await cameraModel.toggleTorch()
                            }
                        }
                    )

                    Spacer()

                    CloseButton {
                        Task {
                            await cameraModel.stop()
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
        .onChange(of: cameraModel.matchedObservations) { _, newObservations in
            if !newObservations.isEmpty { triggerHapticFeedback() }
        }
        .task {
            await cameraModel.start()

            Task { await cameraModel.distributeDisplayFrames() }
            Task { await cameraModel.distributeAnalyzeFrames() }
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
        let zoomFactor = cameraModel.zoomFactor
        Task {
            await cameraModel.zoom(to: zoomFactor * delta)
        }
    }

    private func handleZoomButtonTapped() async {
        if cameraModel.zoomFactor >= 4.0 {
            await cameraModel.zoom(to: 1.0)
        } else if cameraModel.zoomFactor >= 2.0 {
            await cameraModel.zoom(to: 4.0)
        } else {
            await cameraModel.zoom(to: 2.0)
        }
    }

    private func toggleCameraPauseAndShowLock() {
        if cameraModel.isCameraPaused {
            cameraModel.resumeCamera()
        } else {
            cameraModel.pauseCamera()
        }
        showLockTask?.cancel()
        withAnimation {
            showLockIcon = true
        }
        showLockTask = Task {
            try? await Task.sleep(
                for: .seconds(cameraModel.isCameraPaused ? 1 : 0.8)
            )
            if Task.isCancelled { return }
            withAnimation {
                showLockIcon = false
            }
        }
    }
}

// #Preview {
//    CameraView(cameraModel: CameraModel())
// }
