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
            FFIPAppRootView(moduleFactory: ModuleFactory.shared)
                .environment(coordinator)
                .onOpenURL { url in
                    switch url.host {
                    case "search":
                        coordinator.popToRoot()
                    case "voiceSearch":
                        coordinator.push(.voiceSearch)
                    default: break
                    }
                }
        }
        .modelContainer(ffipModelContainer)
    }
}
