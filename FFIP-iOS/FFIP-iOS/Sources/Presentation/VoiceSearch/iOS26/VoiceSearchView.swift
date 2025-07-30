//
//  VoiceSearchView.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import Speech
import SwiftUI

@available(iOS 26.0, *)
struct VoiceSearchView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Bindable var voiceSearchModel: VoiceSearchModel
    @Binding var searchType: SearchType
    
    @State private var transcript: String = ""
    @State private var willCameraPush: Bool = false
    @State private var isUserSpeaking = false
    @State private var showMicButton = false
    
    var body: some View {
        ZStack {
            VStack {
                FfipNavigationBar(
                    leadingType: .back(action: {
                        Task { await handleBackAction() }
                    }),
                    centerType: .none,
                    trailingType: .none
                )
                Spacer()
            }
            .padding(.horizontal, 20)
            
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
                    .accessibilityLabel(.VoiceOverLocalizable.sayKeyword)
                    .accessibilityHint(.VoiceOverLocalizable.voiceInput)
                    .accessibilitySortPriority(1)
                    
                    Spacer()
                }
                .padding(.leading, 30)
                
                HStack {
                    Text(.willCameraPushInstruction)
                        .font(.titleBold24)
                        .foregroundStyle(.ffipGrayscale1)
                        .opacity(willCameraPush ? 1 : 0)
                    Spacer()
                }
                .padding(.leading, 30)
                
                Spacer()
            }
            VStack {
                Spacer()
                
                VoiceListenerView(
                    isUserSpeaking: $isUserSpeaking,
                    showMicButton: $showMicButton
                )
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(.ffipBackground1Main)
        .task {
            transcript = ""
            
            await voiceSearchModel.start()
            
            guard let dictationTranscriber = voiceSearchModel.dictationTranscriber else { return }
            guard let detectorStream = voiceSearchModel.detectorStream else { return }
            
            Task {
                try await handleDictationResults(dictationTranscriber: dictationTranscriber)
            }
            
            Task {
                await handleDetectorStream(detectorStream: detectorStream)
            }
        }
    }
    
    private func handleBackAction() async {
        await voiceSearchModel.stop()
        coordinator.pop()
    }
    
    private func handleDictationResults(dictationTranscriber: DictationTranscriber) async throws {
        for try await case let result in dictationTranscriber.results {
            if showMicButton { return }
            
            let text = String(result.text.characters)
            transcript = text
            
            await voiceSearchModel.stop()
            
            try await Task.sleep(for: .seconds(1))
            
            willCameraPush = true
            
            try await Task.sleep(for: .seconds(1))
            
            switch searchType {
            case .exact:
                coordinator.push(.exactCamera(searchKeyword: transcript))
            case .semantic:
                coordinator.push(.semanticCamera(searchKeyword: transcript))
            }
            break
        }
    }
    
    private func handleDetectorStream(detectorStream: AsyncStream<Float>) async {
        for await db in detectorStream {
            if db > -50 {
                isUserSpeaking = true
                try? await Task.sleep(for: .seconds(2))
            } else {
                isUserSpeaking = false
            }
        }
    }
}

// #Preview {
//    let coordinator = AppCoordinator()
//    VoiceSearchView(voiceSearchModel: VoiceSearchModel(privacyService: PrivacyService(), speechService: SpeechRecognitionService()))
//        .environment(coordinator)
// }
