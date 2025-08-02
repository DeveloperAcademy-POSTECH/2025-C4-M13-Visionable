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
                    case .search: moduleFactory.makeSearchView()
                    case .voiceSearch: moduleFactory.makeVoiceSearchView()
                    case .photoDetail: moduleFactory.makePhotoDetailView()
                    case .onboarding: moduleFactory.makeOnboardingView()
                    }
                }
        }
        .task {
            showOnboardingIfFirstLaunch()
        }
    }
    
    private func showOnboardingIfFirstLaunch() {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: UserDefaultsKey.hasSeenOnboarding)
        if isFirstLaunch {
            coordinator.push(.onboarding)
        }
    }
}
