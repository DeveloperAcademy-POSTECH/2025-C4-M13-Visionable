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
    @State private var searchType: SearchType = .exact
    
    var ffipModelContainer: ModelContainer = {
        let schema = Schema([
            SemanticCameraCapturedImage.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            FFIPAppRootView(
                searchType: $searchType,
                moduleFactory: ModuleFactory.shared
            )
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
                case "voiceSearchSupportVersion":
                    coordinator.push(.voiceSearch)
                    searchType = .exact
                default: break
                }
            }
        }
        .modelContainer(ffipModelContainer)
    }
}
