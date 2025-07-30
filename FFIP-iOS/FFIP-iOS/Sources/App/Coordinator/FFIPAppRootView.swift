//
//  FFIPAppRootView.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

struct FFIPAppRootView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Binding var searchType: SearchType
    
    private let moduleFactory: ModuleFactoryProtocol
    
    public init(
        searchType: Binding<SearchType>,
        moduleFactory: ModuleFactoryProtocol
    ) {
        self._searchType = searchType
        self.moduleFactory = moduleFactory
    }
    
    var body: some View {
        NavigationStack(
            path: Binding(
                get: { coordinator.path },
                set: { coordinator.path = $0 }
            )
        ) {
            moduleFactory.makeSearchView(searchType: $searchType)
                .navigationBarBackButtonHidden(true)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .exactCamera(let searchKeyword): moduleFactory.makeExactCameraView(searchKeyword: searchKeyword)
                    case .semanticCamera(let searchKeyword): moduleFactory.makeSemanticCameraView(searchKeyword: searchKeyword)
                    case .search: moduleFactory.makeSearchView(searchType: $searchType)
                    case .voiceSearch: moduleFactory.makeVoiceSearchView(searchType: $searchType)
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
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.hasSeenOnboarding)
        }
    }
}
