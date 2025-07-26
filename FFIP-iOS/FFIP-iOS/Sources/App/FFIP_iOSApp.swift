//
//  FFIP_iOSApp.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI
import SwiftData

@main
struct FFIP_iOSApp: App {
    @State private var coordinator = AppCoordinator()
    @AppStorage("searchType") var searchType: SearchType = .exact

    var body: some Scene {
        WindowGroup {
            FFIPAppRootView(moduleFactory: ModuleFactory.shared)
                .environment(coordinator)
                .onOpenURL { url in
                    switch url.host {
                    case "searchExact":
                        coordinator.popToRoot()
                        searchType = .exact
                    case "searchSemantic":
                        coordinator.popToRoot()
                        searchType = .semantic
                    case "voiceSearchExact":
                        coordinator.push(.voiceSearch)
                        searchType = .exact
                    case "voiceSearchSemantic":
                        coordinator.push(.voiceSearch)
                        searchType = .semantic
                    default: break
                    }
                }
        }
        .modelContainer(for: [SemanticCameraCapturedImage.self])
    }
}
