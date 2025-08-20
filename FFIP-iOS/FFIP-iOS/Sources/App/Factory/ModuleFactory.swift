//
//  ModuleFactory.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

protocol ModuleFactoryProtocol {
    func makeExactCameraView(searchKeyword: String) -> ExactCameraView
    @available(iOS 26.0, *)
    func makeSemanticCameraView(searchKeyword: String) -> SemanticCameraView
    func makeSearchView() -> SearchView
    @available(iOS 26.0, *)
    func makeVoiceSearchView() -> VoiceSearchView
    func makeVoiceSearchSupportVersionVoew() -> VoiceSearchSupportVersionView
    func makePhotoDetailView() -> PhotoDetailView
    func makeOnboardingView() -> OnboardingView
}

final class ModuleFactory: ModuleFactoryProtocol {
    static let shared = ModuleFactory()
    private init() {}
    
    func makeExactCameraView(searchKeyword: String) -> ExactCameraView {
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
    
    @available(iOS 26.0, *)
    func makeSemanticCameraView(searchKeyword: String) -> SemanticCameraView {
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
        
        let foundationModelsService = FoundationModelsService()
        let languageModel = LanguageModel(foundationModelsService: foundationModelsService)
        
        let cameraMediator = SemanticCameraMediator(
            cameraModel: cameraModel,
            visionModel: visionModel,
            languageModel: languageModel
        )
        
        let view = SemanticCameraView(mediator: cameraMediator)
        return view
    }
    
    func makeSearchView() -> SearchView {
        let keywords = UserDefaults.standard.stringArray(forKey: UserDefaultsKey.recentSearch) ?? []
        let model = SearchModel(recentSearchKeywords: keywords)
        let view = SearchView(searchModel: model)
        return view
    }
    
    @available(iOS 26.0, *)
    func makeVoiceSearchView() -> VoiceSearchView {
        let keywords = UserDefaults.standard.stringArray(forKey: UserDefaultsKey.recentSearch) ?? []
        let searchModel = SearchModel(recentSearchKeywords: keywords)
        
        let privacyService = PrivacyService()
        let speechTranscriptionService = SpeechTranscriptionService()
        let voiceSearchModel = VoiceSearchModel(
            privacyService: privacyService,
            speechService: speechTranscriptionService
        )
        
        let view = VoiceSearchView(
            searchModel: searchModel,
            voiceSearchModel: voiceSearchModel
        )
        return view
    }
    
    func makeVoiceSearchSupportVersionVoew() -> VoiceSearchSupportVersionView {
        let privacyService = PrivacyService()
        let speechRecognitionService = SpeechRecognitionService()
        let model = VoiceSearchSupportVersionModel(
            privacyService: privacyService,
            speechService: speechRecognitionService
        )
        let view = VoiceSearchSupportVersionView(voiceSearchSupportVersionModel: model)
        return view
    }
    
    func makePhotoDetailView() -> PhotoDetailView {
        let view = PhotoDetailView()
        return view
    }
    
    func makeOnboardingView() -> OnboardingView {
        let view = OnboardingView()
        return view
    }
}
