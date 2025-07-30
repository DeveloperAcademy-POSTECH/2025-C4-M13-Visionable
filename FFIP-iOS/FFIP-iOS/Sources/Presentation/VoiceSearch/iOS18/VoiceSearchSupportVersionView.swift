//
//  VoiceSearchSupportVersionView.swift
//  FFIP-iOS
//
//  Created by mini on 7/30/25.
//

import Speech
import SwiftUI

struct VoiceSearchSupportVersionView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Bindable var voiceSearchSupportVersionModel: VoiceSearchSupportVersionModel
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
                        voiceSearchSupportVersionModel.transcript.isEmpty
                            ? String(localized: .searchPlaceholder)
                            : "\"\(voiceSearchSupportVersionModel.transcript)\""
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
            await voiceSearchSupportVersionModel.start()
        }
        .onChange(of: voiceSearchSupportVersionModel.willCameraPush) { _, willCameraPush in
            if willCameraPush {
                if voiceSearchSupportVersionModel.transcript.isEmpty {
                    isUserSpeaking = false
                } else {
                    Task {
                        await voiceSearchSupportVersionModel.stop()
                        try? await Task.sleep(for: .seconds(1))
                        coordinator.push(.exactCamera(searchKeyword: voiceSearchSupportVersionModel.transcript))
                    }
                }
            }
        }
    }

    private func handleBackAction() async {
        await voiceSearchSupportVersionModel.stop()
        coordinator.pop()
    }
}

// #Preview {
//    let coordinator = AppCoordinator()
//    VoiceSearchView(voiceSearchModel: VoiceSearchModel(privacyService: PrivacyService(), speechService: SpeechRecognitionService()))
//        .environment(coordinator)
// }
