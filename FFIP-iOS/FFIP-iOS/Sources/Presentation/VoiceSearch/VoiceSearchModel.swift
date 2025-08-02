//
//  VoiceSearchModel.swift
//  FFIP-iOS
//
//  Created by mini on 7/30/25.
//

import SwiftUI
import Speech

@MainActor
@Observable
final class VoiceSearchModel {
    private let privacyService: PrivacyService
    private var speechRecognitionService: SpeechRecognitionService

    private(set) var transcript: String = ""
    private(set) var willCameraPush: Bool = false

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
            await speechRecognitionService.setOnTranscriptChanged { [weak self] text in
                Task { @MainActor in
                    self?.transcript = text
                }
            }
            await speechRecognitionService.setOnLongSpeechPause { [weak self] in
                Task { @MainActor in
                    try await Task.sleep(for: .seconds(1))
                    self?.willCameraPush = true
                }
            }
        } catch {
            print("transcribe error: \(error.localizedDescription)")
        }
    }
    
    func stop() async {
        await speechRecognitionService.stopTranscribing()
    }
}
