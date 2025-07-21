//
//  VoiceSearchView.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

struct VoiceSearchView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Bindable var voiceSearchModel: VoiceSearchModel

    @State private var isListening = false

    var body: some View {
        VStack(spacing: 20) {
            Text(voiceSearchModel.transcript)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()

            VoiceListenerView(
                isListening: $isListening,
            )

            Button {
                Task {
                    if isListening {
                        await voiceSearchModel.stop()
                        isListening = false
                    } else {
                        await voiceSearchModel.start()
                        isListening = true
                    }
                }
            } label: {
                Image(systemName: isListening ? "mic.fill" : "mic")
                    .font(.system(size: 40))
                    .padding()
                    .background(Circle().fill(isListening ? .red : .blue))
                    .foregroundColor(.white)
            }
        }
        .padding()
    }
}

struct VoiceListenerView: View {
    @Binding var isListening: Bool

    @State private var phase: Int = 0
    @State private var unDetectCount: Int = 0
    @State private var showMicButton: Bool = false

    private let phaseDuration: TimeInterval = 0.3

    var body: some View {
        VStack {
            if showMicButton {
                MicButton(action: {
                    unDetectCount = 0
                    showMicButton = false
                })
            } else {
                HStack(spacing: 13) {
                    ForEach(0..<4, id: \.self) { i in
                        Group {
                            if i == 2 {
                                Circle()
                                    .fill(.ffipPointGreen1)
                            } else {
                                Rectangle()
                                    .fill(.ffipBackground3Pop)
                            }
                        }
                        .frame(
                            width: 12,
                            height: shapeHeight(undDetectCount: unDetectCount)
                        )
                        .padding(
                            .bottom,
                            shapeBottomPadding(
                                index: i,
                                phase: phase,
                                isListening: isListening,
                                unDetectCount: unDetectCount
                            )
                        )
                    }
                }
                .animation(
                    .linear(
                        duration: phaseDuration * (isListening ? 2 / 3 : 1)
                    ),
                    value: phase
                )
                .animation(
                    .linear(
                        duration: phaseDuration * (isListening ? 2 / 3 : 1)
                    ),
                    value: unDetectCount
                )
                .task {
                    while true {
                        if isListening {
                            unDetectCount = 0
                            phase = (phase + 1) % 4
                            try? await Task.sleep(
                                for: .seconds(
                                    phaseDuration * (isListening ? 2 / 3 : 1)
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

    private func shapeHeight(undDetectCount: Int) -> CGFloat {
        if unDetectCount < 7 {
            return 12
        }

        return CGFloat(19 - undDetectCount)
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

// #Preview {
//    let coordinator = AppCoordinator()
//    VoiceSearchView(voiceSearchModel: VoiceSearchModel(privacyService: PrivacyService(), speechService: SpeechRecognitionService()))
//        .environment(coordinator)
// }
