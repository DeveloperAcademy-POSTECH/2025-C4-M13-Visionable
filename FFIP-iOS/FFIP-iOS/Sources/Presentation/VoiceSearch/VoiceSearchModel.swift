//
//  VoiceSearchModel.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI
import Speech

@MainActor
@Observable
final class VoiceSearchModel {
    private let privacyService: PrivacyService
    private let speechService: SpeechTranscriptionService

    private(set) var dictationTranscriber: DictationTranscriber?
    private(set) var detectorStream: AsyncStream<Float>?

    private(set) var isUserSpeaking: Bool = false

    private var listenTranscriptTask: Task<Void, Never>?
    private var listenSpeechDetectedTask: Task<Void, Never>?

    init(
        privacyService: PrivacyService,
        speechService: SpeechTranscriptionService
    ) {
        self.privacyService = privacyService
        self.speechService = speechService
    }

    func start() async {
        await privacyService.fetchMicrophoneAuthorization()

        do {
            try await speechService.startTranscribing()
        } catch {
            print("transcribe error: \(error.localizedDescription)")
        }
        
        dictationTranscriber = await speechService.dictationTranscriber
        detectorStream = await speechService.detectorStream
    }

    func stop() async {
        await speechService.stopTranscribing()
    }
}
