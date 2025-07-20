//
//  SearchType.swift
//  FFIP-iOS
//
//  Created by Jamin on 7/20/25.
//

import SwiftUI

enum SearchType: String, CaseIterable, Identifiable {
    case keyword
    case semantic
    
    var id: String { rawValue }
    
    var title: LocalizedStringResource {
        switch self {
        case .keyword: return .exactSearch
        case .semantic: return .semanticSearch
        }
    }
    
    var placeholder: LocalizedStringResource {
        switch self {
        case .keyword: return .exactSearchPlaceholder
        case .semantic: return .semantictSearchPlaceholder
        }
    }
    
    var tagIcon: ImageResource? {
        switch self {
        case .keyword:
            return nil
        case .semantic:
            return .icnAImark
        }
    }
}
