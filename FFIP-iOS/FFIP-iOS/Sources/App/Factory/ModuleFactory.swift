//
//  ModuleFactory.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

protocol ModuleFactoryProtocol {
    func makeExactCameraView(searchKeyword: String) -> ExactCameraView
    func makeSearchView() -> SearchView
    func makeVoiceSearchView() -> VoiceSearchView
    func makePhotoDetailView() -> PhotoDetailView
    func makeOnboardingView() -> OnboardingView
}

final class ModuleFactory: @preconcurrency ModuleFactoryProtocol {
    @MainActor static let shared = ModuleFactory()
    private init() {}
    
    @MainActor func makeExactCameraView(searchKeyword: String) -> ExactCameraView {
        let privacyService = PrivacyService()
        let captureService = VideoCaptureService()
        let deviceService = VideoDeviceService()
        let cameraModel = CameraModel(
            privacyService: privacyService,
            captureService: captureService,
            deviceService: deviceService
        )
        
        let visionService = VisionService()
        let visionModel = VisionModel(searchKeyword: searchKeyword, visionService: visionService)
        
        let keywords = UserDefaults.standard.stringArray(forKey: UserDefaultsKey.recentSearch) ?? []
        let searchModel = SearchModel(recentSearchKeywords: keywords)
        
        let cameraMediator = ExactCameraMediator(cameraModel: cameraModel, visionModel: visionModel)
        
        let view = ExactCameraView(
            mediator: cameraMediator,
            searchModel: searchModel,
            searchText: searchKeyword
        )
        return view
    }

    @MainActor func makeSearchView() -> SearchView {
        let keywords = UserDefaults.standard.stringArray(forKey: UserDefaultsKey.recentSearch) ?? []
        let model = SearchModel(recentSearchKeywords: keywords)
        let view = SearchView(searchModel: model)
        return view
    }
    
    @MainActor func makeVoiceSearchView() -> VoiceSearchView {
        let privacyService = PrivacyService()
        let speechRecognitionService = SpeechRecognitionService()
        let model = VoiceSearchModel(
            privacyService: privacyService,
            speechService: speechRecognitionService
        )
        let view = VoiceSearchView(voiceSearchModel: model)
        return view
    }
    
    @MainActor func makePhotoDetailView() -> PhotoDetailView {
        let view = PhotoDetailView()
        return view
    }
    
    func makeOnboardingView() -> OnboardingView {
        let view = OnboardingView()
        return view
    }
}
