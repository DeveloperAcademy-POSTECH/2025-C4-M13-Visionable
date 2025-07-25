//
//  VoiceSearchView.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI
import Speech

struct VoiceSearchView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Bindable var voiceSearchModel: VoiceSearchModel
    
    @State private var transcript: String = ""
    @State private var isListening = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 58)
            HStack {
                Text(transcript == "" ? String(localized: .searchPlaceholder) : "\"\(transcript)\"")
                    .font(.titleBold24)
                    .foregroundStyle(.ffipGrayscale1)
                Spacer()
            }
            
            Spacer()
                .frame(height: 165)
            
            VoiceListenerView(
                isListening: voiceSearchModel.isUserSpeaking,
            )
            
            Spacer()
        }
        .padding()
        .task {
            await voiceSearchModel.start()
            
            guard let dictationTranscriber = voiceSearchModel.dictationTranscriber else { return }
            guard let detectorStream = voiceSearchModel.detectorStream else { return }
            
            Task {
                for try await case let result in dictationTranscriber.results {
                    let text = String(result.text.characters)
                    transcript = text
    
                    try await Task.sleep(for: .seconds(1))
                    
                    await voiceSearchModel.stop()
                    coordinator.push(.exactCamera(searchKeyword: transcript))
                
                    try await Task.sleep(for: .seconds(1))
                    transcript = ""
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
