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

// #Preview {
//    let coordinator = AppCoordinator()
//    VoiceSearchView(voiceSearchModel: VoiceSearchModel(privacyService: PrivacyService(), speechService: SpeechRecognitionService()))
//        .environment(coordinator)
// }
