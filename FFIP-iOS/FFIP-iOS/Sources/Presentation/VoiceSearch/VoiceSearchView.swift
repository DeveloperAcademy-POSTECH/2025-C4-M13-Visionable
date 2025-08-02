//
//  VoiceSearchView.swift
//  FFIP-iOS
//
//  Created by mini on 7/30/25.
//

import Speech
import SwiftUI

struct VoiceSearchView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Bindable var voiceSearchModel: VoiceSearchModel
    @Binding var searchType: SearchType

    @State private var willCameraPush: Bool = false
    @State private var isUserSpeaking = true
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
                        voiceSearchModel.transcript.isEmpty
                            ? ".searchPlaceholder"
                            : "\"\(voiceSearchModel.transcript)\""
                    )
                    .font(.titleBold24)
                    .foregroundStyle(.ffipGrayscale1)
                    .accessibilityLabel(".VoiceOverLocalizable.sayKeyword")
                    .accessibilityHint(".VoiceOverLocalizable.voiceInput")
                    .accessibilitySortPriority(1)

                    Spacer()
                }
                .padding(.leading, 30)

                HStack {
                    Text(".willCameraPushInstruction")
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
            await voiceSearchModel.start()
        }
        .onChange(of: voiceSearchModel.willCameraPush) { _, willCameraPush in
            if willCameraPush {
                if voiceSearchModel.transcript.isEmpty {
                    isUserSpeaking = false
                } else {
                    Task {
                        await voiceSearchModel.stop()
                        try? await Task.sleep(for: .seconds(1))
                        coordinator.push(.exactCamera(searchKeyword: voiceSearchModel.transcript))
                    }
                }
            }
        }
    }

    private func handleBackAction() async {
        await voiceSearchModel.stop()
        coordinator.pop()
    }
}

// #Preview {
//    let coordinator = AppCoordinator()
//    VoiceSearchView(voiceSearchModel: VoiceSearchModel(privacyService: PrivacyService(), speechService: SpeechRecognitionService()))
//        .environment(coordinator)
// }
