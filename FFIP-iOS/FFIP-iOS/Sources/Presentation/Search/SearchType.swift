//
//  SearchType.swift
//  FFIP-iOS
//
//  Created by Jamin on 7/20/25.
//

import SwiftUI

enum SearchType: String, CaseIterable, Identifiable {
    case exact
    case semantic
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .exact: return ".exactSearch"
        case .semantic: return ".semanticSearch"
        }
    }
    
    var placeholder: String {
        switch self {
        case .exact: return ".exactSearchPlaceholder"
        case .semantic: return ".semantictSearchPlaceholder"
        }
    }
    
    var tagIcon: ImageResource? {
        switch self {
        case .exact:
            return nil
        case .semantic:
            return .icnAImark
        }
    }
}
