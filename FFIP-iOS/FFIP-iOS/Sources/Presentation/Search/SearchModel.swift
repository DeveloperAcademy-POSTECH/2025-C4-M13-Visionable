//
//  SearchModel.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

@Observable
final class SearchModel {
    private let recentSearchKey = "recentSearchKeywords"
    var searchKeyword: String = ""
    var recentSearchKeywords: [String] = []
    
    func submitSearch() {
        var recent = UserDefaults.standard.stringArray(forKey: recentSearchKey) ?? []
        recent.removeAll(where: { $0 == searchKeyword })
        recent.insert(searchKeyword, at: 0)
        
        recent = Array(recent.prefix(5))
        
        UserDefaults.standard.set(recent, forKey: recentSearchKey)
    }
    
    func fetchRecentSearchKeywords() {
        recentSearchKeywords = UserDefaults.standard.stringArray(forKey: recentSearchKey) ?? []
    }
    
    func deleteRecentSearchKeyword(_ keyword: String) {
        recentSearchKeywords.removeAll(where: { $0 == keyword })
            UserDefaults.standard.set(recentSearchKeywords, forKey: recentSearchKey)
    }
}
