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
    
    var body: some Scene {
        WindowGroup {
            FFIPAppRootView(moduleFactory: ModuleFactory.shared)
                .environment(coordinator)
        }
    }
}
