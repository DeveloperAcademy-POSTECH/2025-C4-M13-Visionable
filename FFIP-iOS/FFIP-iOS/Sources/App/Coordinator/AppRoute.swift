//
//  AppRoute.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import Foundation

enum AppRoute: Hashable {
    case exactCamera(searchKeyword: String)
    case semanticCamera(searchKeyword: String)
    case search
    case voiceSearch(searchType: SearchType)
    case photoDetail
    case onboarding
}
