//
//  SearchModel.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

@Observable
final class SearchModel {
    var searchKeyword: String = ""
    var recentSearchKeyword: [String] = ["최근1", "최근2"]
    
    func submitSearch() {
        // TODO: 검색 키워드 전달하는 로직
    }
    
    func fetchRecentSearchKeywords() {
        // TODO: UserDefaults로 최근 검색어 목록 가져오는 로직
    }
    
    func deleteRecentSearchKeyword(_ keyword: String) {
        // TODO: 해당 keyword를 recentSearchKeyword 배열에서 제거
    }
}
