//
//  SearchModel.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

@Observable
final class SearchModel {
    private(set) var recentSearchKeywords: [String]
    
    init(recentSearchKeywords: [String]) {
        self.recentSearchKeywords = recentSearchKeywords
    }
    
    func addRecentSearchKeyword(_ keyword: String) {
        recentSearchKeywords.removeAll(where: { $0 == keyword })
        recentSearchKeywords.insert(keyword, at: 0)
        recentSearchKeywords = Array(recentSearchKeywords.prefix(5))
        
        UserDefaults.standard.set(recentSearchKeywords, forKey: UserDefaultsKey.recentSearch)
    }
    
    func deleteRecentSearchKeyword(_ keyword: String) {
        recentSearchKeywords.removeAll(where: { $0 == keyword })
        UserDefaults.standard.set(recentSearchKeywords, forKey: UserDefaultsKey.recentSearch)
    }
    
    func deleteAllRecentSearchKeyword() {
        recentSearchKeywords.removeAll()
        UserDefaults.standard.set(recentSearchKeywords, forKey: UserDefaultsKey.recentSearch)
    }
}
