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
    private let speechService: SpeechRecognitionService
    
    private(set) var transcript: String = ""
    
    init(
        privacyService: PrivacyService,
        speechService: SpeechRecognitionService
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
    }
    
    func stop() async {
        await speechService.stopTranscribing()
        transcript = await speechService.getTranscript()
    }
    
}
