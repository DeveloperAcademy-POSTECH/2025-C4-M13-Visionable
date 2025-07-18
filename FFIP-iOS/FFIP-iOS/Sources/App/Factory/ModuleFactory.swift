//
//  ModuleFactory.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

protocol ModuleFactoryProtocol {
    func makeCameraView(searchKeyword: String) -> CameraView
    func makeSearchView() -> SearchView
    func makeVoiceSearchView() -> VoiceSearchView
}

final class ModuleFactory: ModuleFactoryProtocol {
    static let shared = ModuleFactory()
    private init() {}
    
    func makeCameraView(searchKeyword: String) -> CameraView {
        let privacyService = PrivacyService()
        let captureService = VideoCaptureService()
        let deviceService = VideoDeviceService()
        let visionService = VisionService()
        let model = CameraModel(
            searchKeyword: searchKeyword,
            privacyService: privacyService,
            captureService: captureService, deviceService: deviceService, visionService: visionService
        )
        let view = CameraView(cameraModel: model)

        return view
    }
    
    func makeSearchView() -> SearchView {
        let keywords = UserDefaults.standard.stringArray(forKey: UserDefaultsKey.recentSearch) ?? []
        let model = SearchModel(recentSearchKeywords: keywords)
        let view = SearchView(searchModel: model)
        return view
    }
    
    func makeVoiceSearchView() -> VoiceSearchView {
        let privacyService = PrivacyService()
        let speeachService = SpeechRecognitionService()
        let model = VoiceSearchModel(
            privacyService: privacyService,
            speechService: speeachService
        )
        let view = VoiceSearchView(voiceSearchModel: model)
        return view
    }
}
