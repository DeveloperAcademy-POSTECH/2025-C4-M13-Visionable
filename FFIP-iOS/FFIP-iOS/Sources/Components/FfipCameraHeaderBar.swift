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
                ZoomButton(zoomFactor: zoomFactor, action: onZoom)
                Spacer()
                TorchButton(isTorchOn: isTorchOn, action: onToggleTorch)
                Spacer()
                InfoButton(action: onInfo)
                Spacer()
                CloseButton(action: onClose)
            }
            .padding(.horizontal, 16)
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
        
        // TODO: Hi-Fi 디자인 이후 수정
        private struct InfoButton: View {
            let action: () -> Void
            var body: some View {
                Button(action: action) {
                    Image(systemName: "info.circle")
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
    }
