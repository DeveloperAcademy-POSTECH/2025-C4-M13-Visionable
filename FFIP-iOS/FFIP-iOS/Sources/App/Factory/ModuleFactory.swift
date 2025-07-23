//
//  ModuleFactory.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

protocol ModuleFactoryProtocol {
    func makeExactCameraView(searchKeyword: String) -> ExactCameraView
    func makeSemanticCameraView(searchKeyword: String) -> SemanticCameraView
    func makeSearchView() -> SearchView
    func makeVoiceSearchView() -> VoiceSearchView
    func makePhotoDetailView() -> PhotoDetailView
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
        
        let cameraMediator = ExactCameraMediator(cameraModel: cameraModel, visionModel: visionModel)
        
        let view = ExactCameraView(mediator: cameraMediator, searchText: searchKeyword)

        return view
    }
    
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
    
    func makePhotoDetailView() -> PhotoDetailView {
        let view = PhotoDetailView()
        return view
    }
}
