//
//  VoiceSearchModel.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI
import Speech

protocol VoiceSearchModelProtocol {
    func start() async
    func stop() async
}

@available(iOS 26.0, *)
@MainActor
@Observable
final class VoiceSearchModel: VoiceSearchModelProtocol {
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

@MainActor
@Observable
final class VoiceSearchModelSupportVersion: VoiceSearchModelProtocol {
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
