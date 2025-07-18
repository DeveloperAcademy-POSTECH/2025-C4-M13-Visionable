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
    
    private let speechRecognizer: SFSpeechRecognizer?
    private(set) var audioEngine: AVAudioEngine?
    private(set) var audioBufferRequest: SFSpeechAudioBufferRecognitionRequest?
    private(set) var recognitionTask: SFSpeechRecognitionTask?
    
    public init() {
        speechRecognizer = SFSpeechRecognizer()
        if speechRecognizer == nil {
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
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            self.transcribe(RecognizerError.recognizerIsUnavailable)
            return
        }
        
        do {
            let (audioEngine, request) = try Self.prepareRecordingEngine()
            self.audioEngine = audioEngine
            self.audioBufferRequest = request
            recognitionTask = speechRecognizer.recognitionTask(with: request, resultHandler: { [weak self] result, error in
                guard let self else { return }
                self.recognitionHandler(audioEngine: audioEngine, result: result, error: error)
            })
        } catch {
            await self.reset()
            self.transcribe(error)
        }
    }
    
    private func reset() async {
        recognitionTask?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        audioBufferRequest = nil
        recognitionTask = nil
    }
    
    private static func prepareRecordingEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, _: AVAudioTime) in
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
