//
//  VoiceListenerView.swift
//  FFIP-iOS
//
//  Created by SeanCho on 7/22/25.
//

import SwiftUI

struct VoiceListenerView: View {
    @Binding var isUserSpeaking: Bool
    @Binding var showMicButton: Bool

    @State private var phase: Int = 0
    @State private var unDetectCount: Int = 0

    private let phaseDuration: TimeInterval = 0.3

    var body: some View {
        VStack {
            if showMicButton {
                MicButton(action: {
                    unDetectCount = 0
                    showMicButton = false
                })
                .accessibilityLabel(.VoiceOverLocalizable.voiceInput)
                .accessibilityHint(.VoiceOverLocalizable.voiceSearhHint)
                .accessibilityAddTraits(.isButton)
                .accessibilitySortPriority(1)
            } else {
                HStack(spacing: 13) {
                    ForEach(0..<4, id: \.self) { i in
                        Group {
                            if i == 2 {
                                Circle()
                                    .fill(.ffipPointGreen1)
                            } else {
                                Rectangle()
                                    .fill(.ffipGrayscale1)
                            }
                        }
                        .frame(
                            width: 12,
                            height: shapeHeight(unDetectCount: unDetectCount)
                        )
                        .padding(
                            .bottom,
                            shapeBottomPadding(
                                index: i,
                                phase: phase,
                                isListening: isUserSpeaking,
                                unDetectCount: unDetectCount
                            )
                        )
                    }
                }
                .animation(
                    .linear(
                        duration: phaseDuration * (isUserSpeaking ? 2 / 3 : 1)
                    ),
                    value: phase
                )
                .animation(
                    .linear(
                        duration: phaseDuration * (isUserSpeaking ? 2 / 3 : 1)
                    ),
                    value: unDetectCount
                )
                .task {
                    while true {
                        if isUserSpeaking {
                            unDetectCount = 0
                            phase = (phase + 1) % 4
                            try? await Task.sleep(
                                for: .seconds(
                                    phaseDuration * (isUserSpeaking ? 2 / 3 : 1)
                                )
                            )
                        } else {
                            if unDetectCount < 7 {
                                unDetectCount += 1
                                phase = (phase + 1) % 4
                            } else if unDetectCount < 16 {
                                unDetectCount += 1
                            }
                            try? await Task.sleep(for: .seconds(phaseDuration))
                            if unDetectCount == 16 {
                                showMicButton = true
                                break
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 120, height: 120)
        .animation(.default, value: showMicButton)
    }

    private func shapeBottomPadding(
        index: Int,
        phase: Int,
        isListening: Bool,
        unDetectCount: Int
    ) -> CGFloat {
        if unDetectCount > 6 { return 0 }

        let shapeHeightTable: [[CGFloat]] = [
            [0, 0, 12, 6],
            [0, 12, 6, 0],
            [12, 6, 0, 0],
            [6, 0, 0, 12]
        ]

        guard (0..<4).contains(index), (0..<4).contains(phase) else { return 0 }
        return shapeHeightTable[index][phase] * (isListening ? 3 : 1)
    }

    private func shapeHeight(unDetectCount: Int) -> CGFloat {
        if unDetectCount < 7 {
            return 12
        }

        return CGFloat(19 - unDetectCount)
    }
}

private struct MicButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(.btnSoundSearch)
                .resizable()
                .scaledToFit()
                .shadow(color: .black.opacity(0.1), radius: 11)
        }
    }
}
