//
//  VoiceSearchModel.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI
import Speech

@available(iOS 26.0, *)
@MainActor
@Observable
final class VoiceSearchModel {
    private let privacyService: PrivacyService
    private var speechTranscriptionService: SpeechTranscriptionService

    private(set) var dictationTranscriber: DictationTranscriber?
    private(set) var detectorStream: AsyncStream<Float>?

    private var listenTranscriptTask: Task<Void, Never>?
    private var listenSpeechDetectedTask: Task<Void, Never>?

    init(
        privacyService: PrivacyService,
        speechService: SpeechTranscriptionService
    ) {
        self.privacyService = privacyService
        self.speechTranscriptionService = speechService
    }

    func start() async {
        await privacyService.fetchMicrophoneAuthorization()

        do {
            try await speechTranscriptionService.startTranscribing()
        } catch {
            print("transcribe error: \(error.localizedDescription)")
        }
        
        dictationTranscriber = await speechTranscriptionService.dictationTranscriber
        detectorStream = await speechTranscriptionService.detectorStream
    }

    func stop() async {
        await speechTranscriptionService.stopTranscribing()
    }
}
