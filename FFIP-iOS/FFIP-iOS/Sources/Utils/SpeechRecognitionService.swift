//
//  SpeechRecognitionService.swift
//  FFIP-iOS
//
//  Created by Jamin on 7/16/25.
//

@preconcurrency import AVFoundation
import Speech

actor SpeechRecognitionService {
    private enum RecognizerError: Error {
        case nilRecognizer
        case recognizerIsUnavailable
        
        public var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }
    
    private var transcript: String = ""
    
    private let recognizer: SFSpeechRecognizer?
    private(set) var audioEngine: AVAudioEngine?
    private(set) var request: SFSpeechAudioBufferRecognitionRequest?
    private(set) var task: SFSpeechRecognitionTask?
    
    public init() {
        recognizer = SFSpeechRecognizer()
        if recognizer == nil {
            Task { await self.transcribe(RecognizerError.nilRecognizer) }
        }
    }
    
    func startTranscribing() async throws {
        await transcribe()
    }
    
    func stopTranscribing() async {
        await reset()
    }
    
    func getTranscript() -> String {
        transcript
    }
    
    private func transcribe() async {
        guard let recognizer, recognizer.isAvailable else {
            self.transcribe(RecognizerError.recognizerIsUnavailable)
            return
        }
        
        do {
            let (audioEngine, request) = try Self.prepareEngine()
            self.audioEngine = audioEngine
            self.request = request
            task = recognizer.recognitionTask(with: request, resultHandler: { [weak self] result, error in
                guard let self else { return }
                self.recognitionHandler(audioEngine: audioEngine, result: result, error: error)
            })
        } catch {
            await self.reset()
            self.transcribe(error)
        }
    }
    
    private func reset() async {
        task?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
    }
    
    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, request)
    }
    
    nonisolated private func recognitionHandler(
        audioEngine: AVAudioEngine,
        result: SFSpeechRecognitionResult?,
        error: Error?
    ) {
        let isFinal = result?.isFinal ?? false
        let hasError = error != nil

        if isFinal || hasError {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        if let result {
            let message = result.bestTranscription.formattedString
            Task {
                await self.transcribe(message)
            }
        } else if let error {
            Task {
                await self.transcribe(error)
            }
        }
    }

    private func transcribe(_ message: String) {
        self.transcript = message
    }
    
    private func transcribe(_ error: Error) {
        var errorMessage = ""
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }
        self.transcript = "<< \(errorMessage) >>"
    }
}
