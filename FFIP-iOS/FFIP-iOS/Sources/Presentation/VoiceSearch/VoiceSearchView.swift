//
//  VoiceSearchView.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import Speech
import SwiftUI

struct VoiceSearchView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Bindable var voiceSearchModel: VoiceSearchModel

    @State private var transcript: String = ""
    @State private var willCameraPush: Bool = false
    @State private var isListening = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 58)
            HStack {
                Text(
                    transcript == ""
                        ? String(localized: .searchPlaceholder)
                        : "\"\(transcript)\""
                )
                .font(.titleBold24)
                .foregroundStyle(.ffipGrayscale1)

                Spacer()
            }
            .padding(.leading, 30)

            HStack {
                Text(String(localized: .willCameraPushInstruction))
                    .font(.titleBold24)
                    .foregroundStyle(.ffipGrayscale1)
                    .opacity(willCameraPush ? 1 : 0)
                Spacer()
            }
            .padding(.leading, 30)

            Spacer()

            VoiceListenerView(
                isListening: voiceSearchModel.isUserSpeaking,
            )

            Spacer()
        }
        .task {
            transcript = ""

            await voiceSearchModel.start()

            guard
                let dictationTranscriber = voiceSearchModel.dictationTranscriber
            else { return }
            guard let detectorStream = voiceSearchModel.detectorStream else {
                return
            }

            Task {
                for try await case let result in dictationTranscriber.results {
                    let text = String(result.text.characters)
                    transcript = text

                    await voiceSearchModel.stop()

                    try await Task.sleep(for: .seconds(1))

                    willCameraPush = true

                    try await Task.sleep(for: .seconds(1))

                    coordinator.push(
                        .exactCamera(searchKeyword: transcript)
                    )
                    break
                }
            }

            Task {
                for await db in detectorStream {
                    if db > -40 {
                        try await Task.sleep(for: .seconds(5))
                    } else {
                        try await Task.sleep(for: .seconds(5))
                    }
                }
            }
        }
    }
}

// #Preview {
//    let coordinator = AppCoordinator()
//    VoiceSearchView(voiceSearchModel: VoiceSearchModel(privacyService: PrivacyService(), speechService: SpeechRecognitionService()))
//        .environment(coordinator)
// }
