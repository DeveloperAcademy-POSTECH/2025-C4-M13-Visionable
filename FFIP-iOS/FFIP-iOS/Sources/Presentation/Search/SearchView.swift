//
//  SearchView.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

public enum SearchFocusState {
    case home
    case editing
    
    var isHome: Bool { self == .home }
    var isEditing: Bool { self == .editing }
}

struct SearchView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Bindable var searchModel: SearchModel
    
    @FocusState private var isFocused: Bool
    @State private var searchFocusState: SearchFocusState = .home
    @State private var searchText: String = ""
    
    @AppStorage(AppStorageKey.isShowWidgetNoticeSheet)
    private var isShowWidgetNoticeSheet: Bool = true
    
    var body: some View {
        ZStack {
            Color.ffipBackground1Main.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // 홈화면에서 로고 네비바와 탐색 방법 선택
                if searchFocusState.isHome {
                    FfipNavigationBar(
                        leadingType: .logo,
                        centerType: .none,
                        trailingType: .none
                    )
                    
                    Text(.exactSearch)
                        .font(.titleBold24)
                        .tint(.ffipGrayscale1)
                        .padding(.top, 75)
                        .accessibilityLabel(.VoiceOverLocalizable.searchMode("지정 탐색"))
                        .accessibilityValue(.VoiceOverLocalizable.exactSearchModeValue)
                        .accessibilitySortPriority(1)
                }
                
                // 텍스트필드 검색바
                HStack(spacing: 12) {
                    if searchFocusState.isEditing {
                        Button(action: navigationBackButtonTapped) {
                            Image(.icnNavBack)
                        }
                        .accessibilityLabel(.VoiceOverLocalizable.back)
                        .accessibilityHint(.VoiceOverLocalizable.backHint)
                    }
                    
                    FfipSearchTextField(
                        text: $searchText,
                        isFocused: searchFocusState.isEditing,
                        placeholder: String(localized: .exactSearchPlaceholder),
                        onVoiceSearch: {
                            if #available(iOS 26.0, *) {
                                coordinator.push(.voiceSearch)
                            } else {
                                coordinator.push(.voiceSearchSupportVersion)
                            }
                        },
                        onSubmit: {
                            searchModel.addRecentSearchKeyword(searchText)
                            coordinator.push(.exactCamera(searchKeyword: searchText))
                            searchFocusState = .home
                        },
                        withVoiceSearch: searchFocusState.isHome
                    )
                    .focused($isFocused)
                }
                .padding(.top, 16)
                
                if searchFocusState.isHome {
                    if !searchModel.recentSearchKeywords.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(.recentSearchTitle)
                                .font(.labelMedium12)
                                .foregroundStyle(.ffipGrayscale2)
                                .padding(.top, 32)
                                .accessibilityAddTraits(.isHeader)
                            
                            RecentSearchFlow(
                                keywords: searchModel.recentSearchKeywords,
                                onTap: { keyword in
                                    searchModel.addRecentSearchKeyword(keyword)
                                    coordinator.push(.exactCamera(searchKeyword: keyword))
                                },
                                onTapDelete: { keyword in
                                    searchModel.deleteRecentSearchKeyword(keyword)
                                }
                            )
                        }
                    }
                } else {
                    if !searchModel.recentSearchKeywords.isEmpty {
                        VStack(alignment: .trailing, spacing: 12) {
                            VStack(alignment: .leading, spacing: 20) {
                                Text(.recentSearchTitle)
                                    .font(.labelMedium14)
                                    .foregroundStyle(.ffipGrayscale3)
                                
                                RecentSearchList(
                                    keywords: searchModel.recentSearchKeywords,
                                    onTap: { keyword in
                                        searchModel.addRecentSearchKeyword(keyword)
                                        coordinator.push(.exactCamera(searchKeyword: keyword))
                                    },
                                    onTapDelete: { keyword in
                                        withAnimation(
                                            .easeInOut(duration: 0.05)
                                        ) {
                                            searchModel.deleteRecentSearchKeyword(keyword)
                                        }
                                    }
                                )
                            }
                            Text(.recentSearchesCleared)
                                .font(.labelMedium14)
                                .foregroundStyle(.ffipGrayscale2)
                                .onTapGesture {
                                    searchModel.deleteAllRecentSearchKeyword()
                                }
                                .accessibilityLabel(
                                    .VoiceOverLocalizable.deleteRecentAll
                                )
                                .accessibilityHint(
                                    .VoiceOverLocalizable.resetRecentKeywords
                                )
                                .accessibilityAddTraits(.isButton)
                        }
                        .transition(
                            .move(edge: .bottom).combined(with: .opacity)
                        )
                        .padding(.top, 26)
                    } else {
                        VStack {
                            Spacer()
                                .frame(height: 147)
                            Text(.noRecentSearchesMessage)
                                .font(.bodyMedium16)
                                .foregroundStyle(.ffipGrayscale3)
                                .accessibilityLabel(
                                    .VoiceOverLocalizable.noRecentKeyword
                                )
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: isFocused) {
            if isFocused {
                withAnimation(.easeInOut(duration: 0.25)) {
                    searchFocusState = .editing
                }
            }
        }
        .ffipSheet(isPresented: $isShowWidgetNoticeSheet) {
            WidgetNoticeView(addWidgetButtonTapped: {}, passButtonTapped: {})
        }
    }
}

private extension SearchView {
    func navigationBackButtonTapped() {
        searchText = ""
        withAnimation(.easeInOut(duration: 0.25)) {
            searchFocusState = .home
            isFocused = false
        }
    }
}

// #Preview {
//    let coordinator = AppCoordinator()
//    SearchView(searchModel: SearchModel(recentSearchKeywords: ["ㅇㅇ"]))
//        .environment(coordinator)
// }
