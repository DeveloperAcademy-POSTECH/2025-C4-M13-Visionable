//
//  AppRoute.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import Foundation

enum AppRoute: Hashable {
    case camera(searchKeyword: String)
    case search
    case voiceSearch
}
