//
//  SearchView.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

struct SearchView: View {
    private enum SearchFocusState {
        case home, editing
    }
    
    @Environment(AppCoordinator.self) private var coordinator
    @Bindable var searchModel: SearchModel
    @FocusState private var isFocused: Bool
    @State private var focusState: SearchFocusState = .home
    
    var body: some View {
        VStack(alignment: .leading) {
            if focusState == .home {
                Button {
                    // TODO: - 검색 옵션 선택 뷰 액션 추가
                } label: {
                    HStack(spacing: 8) {
                        Text(.exactSearch)
                        Image(systemName: "chevron.down")
                    }
                }
                .tint(.black)
                .padding(.top, 90)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            FfipTextField(
                text: $searchModel.searchKeyword,
                placeholder: String(localized: "searchPlaceholder"),
                onVoiceSearch: {
                    coordinator.push(.voiceSearch)
                },
                onSubmit: {
                    searchModel.submitSearch()
                    coordinator.push(.camera(searchKeyword: searchModel.searchKeyword))
                },
                onEmptySubmit: { }
            )
            .focused($isFocused)
            .padding(.vertical, 12)
            
            if focusState == .editing {
                VStack(alignment: .leading, spacing: 20) {
                    Text(.recentSearchTitle)
                        .font(.caption)
                        .padding(.top, 20)
                    VStack(spacing: 16) {
                        ForEach(searchModel.recentSearchKeyword, id: \.self) { keyword in
                            RecentSearchView(keyword: keyword) {
                                searchModel.deleteRecentSearchKeyword(keyword)
                            }
                        }
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                isFocused = false
            }
        }
        .onChange(of: isFocused) {
            withAnimation(.easeInOut(duration: 0.3)) {
                focusState = isFocused ? .editing : .home
            }
        }
    }
}

// #Preview {
//    let coordinator = AppCoordinator()
//    SearchView(searchModel: SearchModel())
//        .environment(coordinator)
// }
