//
//  SpeechTranscribtionService.swift
//  FFIP-iOS
//
//  Created by Jamin on 7/23/25.
//

@preconcurrency import AVFoundation
import Foundation
import Speech

actor SpeechTranscriptionService {
    private enum TranscriptionError: Error {
        case couldNotDownloadModel
        case failedToSetupRecognitionStream
        case invalidAudioDataType
        case localeNotSupported
        case noInternetForModelDownload
        case audioFilePathNotFound

        var descriptionString: String {
            switch self {
            case .couldNotDownloadModel:
                return "Could not download the model."
            case .failedToSetupRecognitionStream:
                return "Could not set up the speech recognition stream."
            case .invalidAudioDataType:
                return "Unsupported audio format."
            case .localeNotSupported:
                return "This locale is not yet supported by SpeechAnalyzer."
            case .noInternetForModelDownload:
                return
                    "The model could not be downloaded because the user is not connected to internet."
            case .audioFilePathNotFound:
                return "Couldn't write audio to file."
            }
        }
    }

    private var audioEngine: AVAudioEngine?
    private var analyzerFormat: AVAudioFormat?

    private var speechTranscriber: SpeechTranscriber?
    private var dictationTranscriber: DictationTranscriber?
    private var speechDetector: SpeechDetector?
    private var speechAnalyzer: SpeechAnalyzer?
    private var speechStream: AsyncStream<AnalyzerInput>?
    private var speechStreamContinuation:
        AsyncStream<AnalyzerInput>.Continuation?
    private var recognitionTask: Task<Void, Never>?

    private let converter = BufferConverter()
    private(set) var transcript: AttributedString = ""
    var downloadProgress: Progress?

    func startTranscribing() async throws {
        try await prepareSpeechModules()
        try prepareAudioEngine()

        Task {
            try await testSpeechTranscriber()
        }
        
        Task {
            try await testDictationTranscriber()
        }

        Task {
            try await testSpeechDetector()
        }
    }

    func testSpeechTranscriber() async throws {
        guard let speechTranscriber else {
            return
        }
        print("testSpeechTranscriber")
        for try await case let result in speechTranscriber.results {
            let text = result.text
            print("트랜스크라이버 \(text), \(Date.now)")
        }
    }
    
    func testDictationTranscriber() async throws {
        guard let dictationTranscriber else {
            return
        }
        print("testDictationTranscriber")
        for try await case let result in dictationTranscriber.results {
            let text = result.text
            print("딕테이션 \(result), \(Date.now)")
        }
    }
    
    func testSpeechDetector() async throws {
        guard let speechDetector else {
            return
        }
        print("testSpeechDetector")
        for try await case let result in speechDetector.results {
            print("디텍터 \(result), \(Date.now)")
        }
    }

    func stopTranscribing() async {
        audioEngine?.stop()
        speechStreamContinuation?.finish()
        try? await speechAnalyzer?.finalizeAndFinishThroughEndOfInput()
    }

    private func prepareSpeechModules() async throws {
        let selectedLocale = Locale(languageCode: "ko_KR")

        let transcriber = SpeechTranscriber(
            locale: selectedLocale,
            transcriptionOptions: [],
            reportingOptions: [.volatileResults],
            attributeOptions: []
        )
        
        let dictationTranscriber = DictationTranscriber(locale: selectedLocale, preset: .shortDictation)

        let detector = SpeechDetector(
            detectionOptions: .init(sensitivityLevel: .high),
            reportResults: true
        )

        self.speechTranscriber = transcriber
        self.dictationTranscriber = dictationTranscriber
        self.speechDetector = detector

        let modules: [any SpeechModule] = [dictationTranscriber, detector]

        do {
            try await ensureModel(
                transcriber: transcriber,
                locale: selectedLocale
            )
        } catch let error as TranscriptionError {
            print(error)
            return
        }
        
        try? await ensureModel(dictationTranscriber: dictationTranscriber, locale: selectedLocale)

        speechAnalyzer = SpeechAnalyzer(modules: modules)

        guard let speechAnalyzer else { return }

        self.analyzerFormat = await SpeechAnalyzer.bestAvailableAudioFormat(
            compatibleWith: modules
        )

        print("analyzerFormat: \(String(describing: self.analyzerFormat))")

        (speechStream, speechStreamContinuation) = AsyncStream<AnalyzerInput>
            .makeStream()

        guard let speechStream else {
            print("speechStream nil")
            return }

        try await speechAnalyzer.start(inputSequence: speechStream)
    }

    private func prepareAudioEngine() throws {
        print("preapreAudioEngine 시작")
        let audioEngine = AVAudioEngine()

        guard analyzerFormat != nil else {
            throw TranscriptionError.failedToSetupRecognitionStream
        }

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(
            .playAndRecord,
            mode: .measurement,
            options: .duckOthers
        )
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: recordingFormat
        ) { [weak self] buffer, _ in
            guard let self else { return }
            Task {
                try? await self.sendBufferToAnalyzer(buffer)
            }
        }

        audioEngine.prepare()
        try audioEngine.start()
        self.audioEngine = audioEngine
    }

    private func sendBufferToAnalyzer(_ buffer: AVAudioPCMBuffer) async throws {
        guard let speechStreamContinuation, let analyzerFormat else {
            throw TranscriptionError.invalidAudioDataType
        }

        let converted = try await converter.convertBuffer(
            buffer,
            to: analyzerFormat
        )
        let input = AnalyzerInput(buffer: converted)
        speechStreamContinuation.yield(input)
    }

    private func updateSpeechDetected(isDetected: Bool) async {
        print("updateSpeechDetected")
    }
}

extension SpeechTranscriptionService {
    public func ensureModel(transcriber: SpeechTranscriber, locale: Locale)
        async throws
    {
        guard await supported(locale: locale) else {
            throw TranscriptionError.localeNotSupported
        }

        if await installed(locale: locale) {
            return
        } else {
            try await downloadIfNeeded(for: transcriber)
        }
    }
    
    public func ensureModel(dictationTranscriber: DictationTranscriber, locale: Locale)
        async throws
    {
        print("ensureModel \(dictationTranscriber)")
        
        guard await supported(locale: locale) else {
            print("ensureModel supported 실패")
            return
        }
        
        print("깔아보자 \(dictationTranscriber)")
        try await downloadIfNeeded(for: dictationTranscriber)

//        if await installedDictationTranscriber(locale: locale) {
//            print("깔려있음 \(dictationTranscriber)")
//            return
//        } else {
//            print("깔아보자 \(dictationTranscriber)")
//            try await downloadIfNeeded(for: dictationTranscriber)
//        }
    }

    func supported(locale: Locale) async -> Bool {
        let supported = await SpeechTranscriber.supportedLocales
        return supported.map { $0.identifier(.bcp47) }.contains(
            locale.identifier(.bcp47)
        )
    }

    func installed(locale: Locale) async -> Bool {
        let installed = await Set(SpeechTranscriber.installedLocales)
        return installed.map { $0.identifier(.bcp47) }.contains(
            locale.identifier(.bcp47)
        )
    }
    
    func installedDictationTranscriber(locale: Locale) async -> Bool {
        let installed = await Set(DictationTranscriber.installedLocales)
        return installed.map { $0.identifier(.bcp47) }.contains(
            locale.identifier(.bcp47)
        )
    }

    func downloadIfNeeded(for module: SpeechTranscriber) async throws {
        if let downloader = try await AssetInventory.assetInstallationRequest(
            supporting: [module])
        {
            self.downloadProgress = downloader.progress
            try await downloader.downloadAndInstall()
        }
    }
    
    func downloadIfNeeded(for module: DictationTranscriber) async throws {
        if let downloader = try await AssetInventory.assetInstallationRequest(
            supporting: [module])
        {
            print("다운로드 \(module)")
            self.downloadProgress = downloader.progress
            try await downloader.downloadAndInstall()
        } else { print("다운로드 \(module) 실패")}
    }

    func deallocate() async {
        let allocated = await AssetInventory.allocatedLocales
        for locale in allocated {
            await AssetInventory.deallocate(locale: locale)
        }
    }
}
final class BufferConverter {
    enum Error: Swift.Error {
        case failedToCreateConverter
        case failedToCreateConversionBuffer
        case conversionFailed(NSError?)
    }

    private var converter: AVAudioConverter?

    func convertBuffer(_ buffer: AVAudioPCMBuffer, to format: AVAudioFormat)
        throws -> AVAudioPCMBuffer
    {
        let inputFormat = buffer.format
        guard inputFormat != format else {
            return buffer
        }

        if converter == nil || converter?.outputFormat != format {
            converter = AVAudioConverter(from: inputFormat, to: format)
            converter?.primeMethod = .none
        }

        guard let converter else {
            throw Error.failedToCreateConverter
        }

        let sampleRateRatio =
            converter.outputFormat.sampleRate / converter.inputFormat.sampleRate
        let scaledInputFrameLength =
            Double(buffer.frameLength) * sampleRateRatio
        let frameCapacity = AVAudioFrameCount(
            scaledInputFrameLength.rounded(.up)
        )

        guard
            let conversionBuffer = AVAudioPCMBuffer(
                pcmFormat: converter.outputFormat,
                frameCapacity: frameCapacity
            )
        else {
            throw Error.failedToCreateConversionBuffer
        }

        var nsError: NSError?

        let status = converter.convert(
            to: conversionBuffer,
            error: &nsError,
            withInputFrom: { _, inputStatusPointer in
                inputStatusPointer.pointee = .haveData
                return buffer
            }
        )

        guard status != .error else {
            throw Error.conversionFailed(nsError)
        }

        return conversionBuffer
    }
}

extension SpeechDetector: @retroactive SpeechModule, @unchecked @retroactive Sendable {}
