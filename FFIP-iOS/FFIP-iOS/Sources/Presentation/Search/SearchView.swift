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
    @Binding var searchType: SearchType
    
    @FocusState private var isFocused: Bool
    @State private var searchFocusState: SearchFocusState = .home
    @State private var isToolTipPresented: Bool = false
    @State private var isSheetPresented: Bool = false
    @State private var isToastPresented: Bool = false
    @State private var searchText: String = ""
    
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
                    
                    if #available(iOS 26.0, *) {
                        Button {
                            withAnimation { isSheetPresented = true }
                        } label: {
                            HStack(spacing: 8) {
                                Text(searchType.title)
                                    .font(.titleBold24)
                                Image(.icnKeyboardArrowDown)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20)
                                    .ffipToolTip(
                                        isToolTipVisible: $isToolTipPresented,
                                        message: String(localized: searchType == .exact ? .exactSearchToolTip : .semanticSearchToolTip),
                                        position: .trailing,
                                        spacing: 9
                                    )
                            }
                        }
                        .tint(.ffipGrayscale1)
                        .padding(.top, 75)
                        .accessibilityLabel(
                            .VoiceOverLocalizable.searchMode(
                                searchType == .exact ? "지정 탐색" : "연관 탐색"
                            )
                        )
                        .accessibilityValue(
                            searchType == .exact
                            ? .VoiceOverLocalizable.exactSearchModeValue
                            : .VoiceOverLocalizable.semanticSearchModeValue
                        )
                        .accessibilityHint(.VoiceOverLocalizable.changeSearchMode)
                        .accessibilityAddTraits(.isButton)
                        .accessibilitySortPriority(1)
                    } else {
                        Text(searchType.title)
                            .font(.titleBold24)
                            .tint(.ffipGrayscale1)
                            .padding(.top, 75)
                            .accessibilityLabel(.VoiceOverLocalizable.searchMode("지정 탐색"))
                            .accessibilityValue(.VoiceOverLocalizable.exactSearchModeValue)
                            .accessibilitySortPriority(1)
                    }
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
                        placeholder: String(localized: searchType.placeholder),
                        onVoiceSearch: {
                            if #available(iOS 26.0, *) {
                                coordinator.push(.voiceSearch)
                            } else {
                                coordinator.push(.voiceSearchSupportVersion)
                            }
                        },
                        onSubmit: {
                            if searchType == .exact {
                                searchModel.addRecentSearchKeyword(searchText)
                            }
                            coordinator.push(
                                searchType == .exact
                                ? .exactCamera(searchKeyword: searchText)
                                : .semanticCamera(searchKeyword: searchText)
                            )
                            
                            searchFocusState = .home
                        },
                        withVoiceSearch: searchFocusState.isHome
                    )
                    .focused($isFocused)
                }
                .padding(.top, 16)
                
                // 지정탐색 일 때만 하단에 뜨는 최근 탐색어 (by 검색모드)
                if searchFocusState.isHome && searchType == .exact {
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
                }
                
                // 지정탐색일 때만 하단에 뜨는 최근 탐색어 (by 편집모드)
                if searchFocusState.isEditing && searchType == .exact {
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
        .onAppear { searchViewWillAppear() }
        .onChange(of: isFocused) {
            if isFocused {
                withAnimation(.easeInOut(duration: 0.25)) {
                    searchFocusState = .editing
                }
            }
        }
        .onChange(of: searchType) {
            withAnimation { isToastPresented = true }
        }
        .ffipSheet(isPresented: $isSheetPresented) {
            SearchTypeSelectionView(
                selectedType: $searchType,
                dismissAction: dismissFfipSheet
            )
        }
        .showFfipToastMessage(
            toastType: .check,
            toastTitle: String(localized: .searchModeUpdated),
            isToastVisible: $isToastPresented
        )
    }
}

private extension SearchView {
    func searchViewWillAppear() {
        searchText = ""
        Task {
            try? await Task.sleep(for: .seconds(0.2))
            withAnimation { isToolTipPresented = true }
        }
    }
    
    func navigationBackButtonTapped() {
        searchText = ""
        withAnimation(.easeInOut(duration: 0.25)) {
            searchFocusState = .home
            isFocused = false
        }
    }
    
    func dismissFfipSheet() {
        if isToolTipPresented { isToolTipPresented = false }
        
        withAnimation { isSheetPresented = false }
        Task {
            try? await Task.sleep(for: .seconds(0.2))
            withAnimation { isToolTipPresented = true }
        }
    }
}

// #Preview {
//    let coordinator = AppCoordinator()
//    SearchView(searchModel: SearchModel(recentSearchKeywords: ["ㅇㅇ"]))
//        .environment(coordinator)
// }
