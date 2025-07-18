//
//  AppRoute.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import Foundation

enum AppRoute: Hashable {
    case exactCamera(searchKeyword: String)
    case relatedCamera(searchKeyword: String)
    case search
    case voiceSearch
}
