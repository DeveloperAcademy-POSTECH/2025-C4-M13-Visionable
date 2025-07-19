//
//  CameraTopBar.swift
//  FFIP-iOS
//
//  Created by SeanCho on 7/18/25.
//

import SwiftUI

struct FfipCameraHeaderBar: View {
    let zoomFactor: CGFloat
    let onZoom: () -> Void
    let isTorchOn: Bool
    let onToggleTorch: () -> Void
    let onInfo: () -> Void
    let onClose: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            HStack(spacing: 0) {
                ZoomButton(zoomFactor: zoomFactor, action: onZoom)
                Spacer()
            }
            .frame(maxWidth: 50)
            Spacer()
            TorchButton(isTorchOn: isTorchOn, action: onToggleTorch)
            Spacer()
            InfoButton(action: onInfo)
            Spacer()
            CloseButton(action: onClose)
        }
        .padding(.horizontal, 20)
        .padding(.top, 67)
        .padding(.bottom, 100)
        .background(
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.06, blue: 0.07), Color(red: 0.04, green: 0.06, blue: 0.07).opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // TODO: Hi-Fi 디자인 이후 수정
    private struct ZoomButton: View {
        let zoomFactor: CGFloat
        let action: () -> Void

        var body: some View {
            let zoomFactor = zoomFactor / 2
            let zoomText: String
            if zoomFactor.truncatingRemainder(dividingBy: 1) < 0.1 {
                zoomText = String(format: "%.0fx", zoomFactor)
            } else {
                zoomText = String(format: "%.1fx", zoomFactor)
            }
            return Button(action: action) {
                Text(zoomText)
                    .foregroundColor(.ffipGrayScaleDefault2)
                    .font(.labelMedium18)
            }
        }
    }

    // TODO: Hi-Fi 디자인 이후 수정
    private struct TorchButton: View {
        let isTorchOn: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(isTorchOn ? "btn_camera_torch" : "btn_camera_torch_slash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            }
            .frame(maxWidth: 50)
        }
    }

    // TODO: Hi-Fi 디자인 이후 수정
    private struct InfoButton: View {
        let action: () -> Void
        var body: some View {
            Button(action: action) {
                Image("btn_camera_info")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            }
            .frame(maxWidth: 50)
        }
    }
    // TODO: Hi-Fi 디자인 이후 수정
    private struct CloseButton: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image("btn_camera_close")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            }
            .frame(maxWidth: 50)
        }
    }
}
