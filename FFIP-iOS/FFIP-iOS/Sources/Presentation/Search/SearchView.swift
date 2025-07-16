//
//  SearchView.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

enum SearchFocusState {
    case home
    case editing
}

struct SearchView: View {
    
    @Environment(AppCoordinator.self) private var coordinator
    @Bindable var searchModel: SearchModel
    @FocusState private var isFocused: Bool
    @State private var focusState: SearchFocusState = .home
    @State private var searchText: String = ""
    
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
            
            FfipSearchTextField(
                text: $searchText,
                isExistVoiceSeachButton: focusState == .home,
                placeholder: String(localized: "searchPlaceholder"),
                onVoiceSearch: {
                    coordinator.push(.voiceSearch)
                },
                onSubmit: {
                    searchModel.addRecentSearchKeyword(searchText)
                    coordinator.push(.camera(searchKeyword: searchText))
                },
                onEmptySubmit: { }
            )
            .focused($isFocused)
            .padding(.vertical, 12)
            
            if focusState == .home {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(searchModel.recentSearchKeywords, id: \.self) { keyword in
                        FfipRecentSearchCapsule(
                            keyword: keyword,
                            onTap: {
                                searchModel.addRecentSearchKeyword(keyword)
                                coordinator.push(.camera(searchKeyword: keyword))
                            },
                            onTapDelete: {
                                searchModel.deleteRecentSearchKeyword(keyword)
                            }
                        )
                    }
                }
            }
            
            if focusState == .editing {
                VStack(alignment: .leading, spacing: 20) {
                    Text(.recentSearchTitle)
                        .font(.caption)
                        .padding(.top, 20)
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(searchModel.recentSearchKeywords, id: \.self) { keyword in
                            RecentSearchRow(
                                keyword: keyword,
                                onTap: {
                                    searchModel.addRecentSearchKeyword(keyword)
                                    coordinator.push(.camera(searchKeyword: keyword))
                                },
                                onTapDelete: {
                                    searchModel.deleteRecentSearchKeyword(keyword)
                                }
                            )
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
            isFocused = false
        }
        .onAppear {
            searchText = ""
        }
        .onChange(of: isFocused) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    focusState = isFocused ? .editing : .home
                }
            }
        }
    }
}

// #Preview {
//    let coordinator = AppCoordinator()
//    SearchView(searchModel: SearchModel())
//        .environment(coordinator)
// }
