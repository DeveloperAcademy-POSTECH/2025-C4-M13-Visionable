//
//  FFIPAppRootView.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

struct FFIPAppRootView: View {
    @Environment(AppCoordinator.self) private var coordinator
    
    private let moduleFactory: ModuleFactoryProtocol
    
    public init(
        moduleFactory: ModuleFactoryProtocol
    ) {
        self.moduleFactory = moduleFactory
    }
    
    var body: some View {
        NavigationStack(
            path: Binding(
                get: { coordinator.path },
                set: { coordinator.path = $0 }
            )
        ) {
            moduleFactory.makeSearchView()
                .navigationBarBackButtonHidden(true)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .exactCamera(let searchKeyword): moduleFactory.makeExactCameraView(searchKeyword: searchKeyword)
                    case .semanticCamera(let searchKeyword):
                        if #available(iOS 26.0, *) {
                            moduleFactory.makeSemanticCameraView(searchKeyword: searchKeyword)
                        }
                    case .search: moduleFactory.makeSearchView()
                    case .voiceSearch:
                        if #available(iOS 26.0, *) {
                            moduleFactory.makeVoiceSearchView()
                        }
                    case .voiceSearchSupportVersion: moduleFactory.makeVoiceSearchSupportVersionVoew()
                    case .photoDetail: moduleFactory.makePhotoDetailView()
                    case .onboarding: moduleFactory.makeOnboardingView()
                    }
                }
        }
        .task {
            coordinator.push(.onboarding)
        }
    }
}
