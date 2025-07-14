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
    @State private var focusPoint: CGPoint = .zero
    @State private var showFocusRectangle = false
    @State private var focusTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                FrameView(image: cameraModel.frameToDisplay)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                showFocusRectangle = true
                                focusPoint = value.location
                            }
                            .onEnded { value in
                                focusTask?.cancel()
                                focusTask = Task {
                                    await handleFocus(
                                        at: value.location,
                                        in: geometry
                                    )
                                }
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                showFocusRectangle = false
                                handleZoomGestureChanged(value)
                            }
                            .onEnded { _ in
                                zoomGestureValue = 1.0
                            }
                    )

                if showFocusRectangle {
                    Rectangle()
                        .stroke(Color.green, lineWidth: 2)
                        .frame(width: 64, height: 64)
                        .position(focusPoint)
                        .opacity(0.8)
                        .shadow(radius: 1)
                        .clipped()
                }
            }

            // TODO: - 박스 영역 디자인 완료 후 수정
            ForEach(cameraModel.matchedObservations, id: \.self) {
                observation in
                Box(observation: observation)
                    .stroke(.red, lineWidth: 1)
            }

            VStack {
                HStack {
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
                    .padding(16)
                    Spacer()
                    CloseButton {
                        coordinator.pop()
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
        }
    }

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

    private func handleFocus(at point: CGPoint, in geometry: GeometryProxy)
        async
    {
        focusPoint = point
        let computedPoint = CGPoint(
            x: point.y / geometry.size.height,
            y: 1 - point.x / geometry.size.width
        )
        await cameraModel.focus(at: computedPoint)
        try? await Task.sleep(for: Duration.seconds(1))
        if Task.isCancelled { return }
        showFocusRectangle = false
    }
}

// #Preview {
//    CameraView(cameraModel: CameraModel())
// }
