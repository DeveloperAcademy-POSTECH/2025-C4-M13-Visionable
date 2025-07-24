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
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 58)
            HStack {
                Text("\"\(voiceSearchModel.transcript)\"")
                    .font(.titleBold24)
                    .foregroundStyle(.ffipGrayscale1)
                Spacer()
            }
            
            Spacer()
                .frame(height: 165)
            
            VoiceListenerView(
                isListening: voiceSearchModel.isListening,
            )
            
            Spacer()
        }
        .padding()
        .task {
            await voiceSearchModel.start()
        }
    }
    
}

// #Preview {
//    let coordinator = AppCoordinator()
//    VoiceSearchView(voiceSearchModel: VoiceSearchModel(privacyService: PrivacyService(), speechService: SpeechRecognitionService()))
//        .environment(coordinator)
// }
