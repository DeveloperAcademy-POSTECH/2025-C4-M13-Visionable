//
//  ModuleFactory.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

protocol ModuleFactoryProtocol {
    func makeCameraView() -> CameraView
    func makeSearchView() -> SearchView
    func makeVoiceSearchView() -> VoiceSearchView
}

final class ModuleFactory: ModuleFactoryProtocol {
    static let shared = ModuleFactory()
    private init() {}
    
    func makeCameraView() -> CameraView {
        let model = CameraModel()
        let view = CameraView(cameraModel: model)
        return view
    }
    
    func makeSearchView() -> SearchView {
        let model = SearchModel()
        let view = SearchView(searchModel: model)
        return view
    }
    
    func makeVoiceSearchView() -> VoiceSearchView {
        let model = VoiceSearchModel()
        let view = VoiceSearchView(voiceSearchModel: model)
        return view
    }
}
