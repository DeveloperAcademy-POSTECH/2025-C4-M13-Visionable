//
//  VoiceSearchModel.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

@MainActor
@Observable
final class VoiceSearchModel {
    private let privacyService: PrivacyService
    private let speechService: SpeechTranscriptionService
//    private let speechService: SpeechRecognitionService
    
    private(set) var transcript: String = String(localized: .exactSearchPlaceholder)
    private(set) var isListening: Bool = false
    
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
                    transcript = "<< 에러: \(error.localizedDescription) >>"
                }
//        listenTranscriptTask?.cancel()
//        listenSpeechDetectedTask?.cancel()
//
//        listenTranscriptTask = Task {
//            for await text in await speechService.transcriptStream {
//                await MainActor.run {
//                    self.transcript = text
//                }
//            }
//        }
//
//        listenSpeechDetectedTask = Task {
//            for await isDetected in await speechService.speechDetectedStream {
//                await MainActor.run {
//                    self.isListening = isDetected
//                }
//            }
//        }
//
//        try? await speechService.startTranscribing()
        
    }
    
    func stop() async {
        await speechService.stopTranscribing()
        //        listenTranscriptTask?.cancel()
        //        listenSpeechDetectedTask?.cancel()
        //        await speechService.stopTranscribing()
    }
}
