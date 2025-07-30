//
//  VoiceSearchSupportVersionModel.swift
//  FFIP-iOS
//
//  Created by mini on 7/30/25.
//

import SwiftUI
import Speech

@MainActor
@Observable
final class VoiceSearchSupportVersionModel {
    private let privacyService: PrivacyService
    private var speechRecognitionService: SpeechRecognitionService

    private var listenTranscriptTask: Task<Void, Never>?
    private var listenSpeechDetectedTask: Task<Void, Never>?

    init(
        privacyService: PrivacyService,
        speechService: SpeechRecognitionService
    ) {
        self.privacyService = privacyService
        self.speechRecognitionService = speechService
    }

    func start() async {
        await privacyService.fetchMicrophoneAuthorization()

        do {
            try await speechRecognitionService.startTranscribing()
        } catch {
            print("transcribe error: \(error.localizedDescription)")
        }
    }
    
    func stop() async {
        await speechRecognitionService.stopTranscribing()
    }
}
