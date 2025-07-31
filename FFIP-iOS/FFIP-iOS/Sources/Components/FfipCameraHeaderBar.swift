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
            FfipInfoButton(action: onInfo)
            Spacer()
            FfipCloseButton(action: onClose)
        }
        .padding(.horizontal, 20)
        .padding(.top, 67)
        .padding(.bottom, 100)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.06, blue: 0.07),
                    Color(red: 0.04, green: 0.06, blue: 0.07).opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private struct ZoomButton: View {
        let zoomFactor: CGFloat
        let action: () -> Void

        var body: some View {
            var zoomFactor = zoomFactor / 2
            zoomFactor = CGFloat(Int(zoomFactor * 10))
            zoomFactor /= 10
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

    private struct TorchButton: View {
        let isTorchOn: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(isTorchOn ? .btnCameraTorch : .btnCameraTorchSlash)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 22)
            }
            .frame(maxWidth: 50)
        }
    }
}

