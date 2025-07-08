//
//  AppCoordinator.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import Combine
import SwiftUI

@MainActor
@Observable
final class AppCoordinator: ObservableObject {
    var path = NavigationPath()

    /// push : 다음 화면으로 넘어갈 때 사용하는 메서드 (_ route 부분에 전환하고자 하는 다음 화면 명시)
    func push(_ route: AppRoute) {
        path.append(route)
    }
    
    /// pop : 이전 화면으로 돌아갈 때 사용하는 메서드
    func pop() {
        path.removeLast()
    }
    
    /// popToRoot : path에 쌓여있는 모든 화면을 지우고, 루트로 돌아가도록 하는 메서드
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    // TODO: - 추가로 필요한 화면 전환 방식에 대해서 아래 부분에 해당 주석을 지우고 추가할 것 !
}
