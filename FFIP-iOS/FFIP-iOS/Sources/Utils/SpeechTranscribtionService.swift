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
    private var audioEngine: AVAudioEngine?
    private var analyzerFormat: AVAudioFormat?

    private(set) var dictationTranscriber: DictationTranscriber?
    private var speechDetector: SpeechDetector?
    private var speechAnalyzer: SpeechAnalyzer?
    private var speechStream: AsyncStream<AnalyzerInput>?
    private var speechStreamContinuation:
        AsyncStream<AnalyzerInput>.Continuation?
    private(set) var detectorStream: AsyncStream<Float>?
    private var detectorStreamContinuation: AsyncStream<Float>.Continuation?
    private var recognitionTask: Task<Void, Never>?

    private let converter = BufferConverter()
    private(set) var transcript: AttributedString = ""
    var downloadProgress: Progress?

    func startTranscribing() async throws {
        try await prepareSpeechModules()
        try prepareAudioEngine()

        // 향후 애플이 업데이트하면 테스트하고 쓰면 돼요.
        //        Task {
        //            try await testSpeechDetector()
        //        }
    }

    func testDictationTranscriber() async throws {
        guard let dictationTranscriber else {
            return
        }
        print("testDictationTranscriber")
        for try await case let result in dictationTranscriber.results {
            let text = result.text
            print("딕테이션 \(text), \(Date.now)")
        }
    }

    // 향후 애플이 업데이트하면 쓰면 돼요.
    //    func testSpeechDetector() async throws {
    //        guard let speechDetector else {
    //            return
    //        }
    //        print("testSpeechDetector")
    //        for try await case let result in speechDetector.results {
    //            print("디텍터 \(result), \(Date.now)")
    //        }
    //    }

    func testDetectorStream() async throws {
        guard let detectorStream else {
            return
        }
        print("testDetectorStream")
        for await db in detectorStream {
            print("데시벨 \(db)")
        }
    }

    func stopTranscribing() async {
        audioEngine?.stop()
        speechStreamContinuation?.finish()
        detectorStreamContinuation?.finish()
        try? await speechAnalyzer?.finalizeAndFinishThroughEndOfInput()
    }

    private func prepareSpeechModules() async throws {
        let selectedLocale = Locale.current

        let dictationTranscriber = DictationTranscriber(
            locale: selectedLocale,
            preset: .shortDictation
        )

        let detector = SpeechDetector(
            detectionOptions: .init(sensitivityLevel: .high),
            reportResults: true
        )

        self.dictationTranscriber = dictationTranscriber
        self.speechDetector = detector

        let modules: [any SpeechModule] = [dictationTranscriber, detector]

        try await ensureModel(
            transcriber: dictationTranscriber,
            locale: selectedLocale
        )

        try? await ensureModel(
            transcriber: dictationTranscriber,
            locale: selectedLocale
        )

        speechAnalyzer = SpeechAnalyzer(modules: modules)

        guard let speechAnalyzer else { return }

        self.analyzerFormat = await SpeechAnalyzer.bestAvailableAudioFormat(
            compatibleWith: modules
        )

        print("analyzerFormat: \(String(describing: self.analyzerFormat))")

        (speechStream, speechStreamContinuation) = AsyncStream<AnalyzerInput>
            .makeStream()
        (detectorStream, detectorStreamContinuation) = AsyncStream<Float>
            .makeStream(bufferingPolicy: .bufferingNewest(1))

        guard let speechStream else {
            print("speechStream nil")
            return
        }

        try await speechAnalyzer.start(inputSequence: speechStream)
    }

    private func prepareAudioEngine() throws {
        print("preapreAudioEngine 시작")
        let audioEngine = AVAudioEngine()

        guard analyzerFormat != nil else { return }

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
            let calculatedMicLevel = calculateMicLevel(from: buffer)

            Task {
                await sendMicLevelToStream(calculatedMicLevel)
            }

            Task {
                try? await self.sendBufferToAnalyzer(buffer)
            }
        }

        audioEngine.prepare()
        try audioEngine.start()
        self.audioEngine = audioEngine
    }

    private func sendBufferToAnalyzer(_ buffer: AVAudioPCMBuffer) async throws {
        guard let speechStreamContinuation, let analyzerFormat else { return }

        let converted = try await converter.convertBuffer(
            buffer,
            to: analyzerFormat
        )
        let input = AnalyzerInput(buffer: converted)
        speechStreamContinuation.yield(input)
    }

    private func sendMicLevelToStream(_ level: Float) {
        guard let detectorStreamContinuation else { return }
        detectorStreamContinuation.yield(level)
    }

    nonisolated private func calculateMicLevel(from buffer: AVAudioPCMBuffer)
        -> Float {
        guard let floatChannelData = buffer.floatChannelData?[0] else {
            return -70
        }
        let frameLength = Int(buffer.frameLength)
        var sum: Float = 0
        for i in 0..<frameLength {
            sum += floatChannelData[i] * floatChannelData[i]
        }
        let rms = sqrt(sum / Float(frameLength))
        let avgPower = 20 * log10(rms)
        return avgPower
    }
}

extension SpeechTranscriptionService {
    public func ensureModel(transcriber: DictationTranscriber, locale: Locale)
        async throws {

        guard await supported(locale: locale) else { return }

        if await installedDictationTranscriber(locale: locale) {
            return
        } else {
            try await downloadIfNeeded(for: transcriber)
        }
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

    func downloadIfNeeded(for module: DictationTranscriber) async throws {
        if let downloader = try await AssetInventory.assetInstallationRequest(
            supporting: [module])
        {
            self.downloadProgress = downloader.progress
            try await downloader.downloadAndInstall()
        }
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
        throws -> AVAudioPCMBuffer {
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

extension SpeechDetector: @retroactive SpeechModule,
    @unchecked @retroactive Sendable {}
