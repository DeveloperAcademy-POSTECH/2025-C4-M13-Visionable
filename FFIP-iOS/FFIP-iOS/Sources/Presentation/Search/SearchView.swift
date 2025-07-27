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
}

struct SearchView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Bindable var searchModel: SearchModel
    @AppStorage("searchType") var searchType: SearchType = .exact
    @FocusState private var isFocused: Bool
    @State private var isToolTipPresented: Bool = false
    @State private var isSheetPresented: Bool = false
    @State private var focusState: SearchFocusState = .home
    @State private var searchText: String = ""
    @State private var hasSearchTypeChanged: Bool = false
    
    var body: some View {
        ZStack {
            Color.ffipBackground1Main.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                if focusState == .home {
                    FfipNavigationBar(leadingType: .logo, centerType: .none, trailingType: .none)
                    
                    Button {
                        withAnimation {
                            isSheetPresented = true
                        }
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
                                    message: searchType == .exact
                                    ? String(localized: .exactSearchToolTip) : String(localized: .semanticSearchToolTip),
                                    position: .trailing,
                                    spacing: 9
                                )
                        }
                    }
                    .tint(.ffipGrayscale1)
                    .padding(.top, 75)
                    .accessibilityLabel("탐색 모드: \(searchType == .exact ? "지정 탐색" : "연관 탐색").")
                    .accessibilityValue(searchType == .exact ? "탐색창에 입력하는 텍스트와 연관된 모든 항목을 찾습니다. 정확한 명칭을 입력하지 않아도 AI로 추론하여 비슷한 항목을 탐색합니다." : "탐색창에 입력하는 텍스트와 정확히 일치하는 항목만 찾아줍니다.")
                    .accessibilityHint("눌러서 탐색모드를 변경할 수 있습니다.")
                    .accessibilityAddTraits(.isButton)
                    .accessibilitySortPriority(1)
                }

                HStack(spacing: 12) {
                    if focusState == .editing {
                        Button {
                            searchText = ""
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    focusState = .home
                                    isFocused = false
                                }
                            }
                        } label: {
                            Image(.icnNavBack)
                        }
                        .accessibilityLabel("뒤로가기")
                        .accessibilityHint("탐색 모드를 변경할 수 있는 초기 화면으로 돌아갑니다.")
                    }
                    
                    FfipSearchTextField(
                        text: $searchText,
                        isFocused: focusState == .editing,
                        placeholder: String(localized: searchType.placeholder),
                        onVoiceSearch: {
                            coordinator.push(.voiceSearch)
                        },
                        onSubmit: {
                            searchModel.addRecentSearchKeyword(searchText)
                            print("\(searchType)")
                            if searchType == .exact {
                                coordinator.push(.exactCamera(searchKeyword: searchText))
                            } else {
                                coordinator.push(.semanticCamera(searchKeyword: searchText))
                            }
                            
                        },
                        onEmptySubmit: { }
                    )
                    .focused($isFocused)
                }
                .padding(.top, 16)
                
                if focusState == .home && searchType == .exact {
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
                                    if searchType == .exact {
                                        coordinator.push(.exactCamera(searchKeyword: keyword))
                                    } else {
                                        coordinator.push(.semanticCamera(searchKeyword: keyword))
                                    }
                                },
                                onTapDelete: { keyword in
                                    searchModel.deleteRecentSearchKeyword(keyword)
                                }
                            )
                        }
                    }
                }
                
                if focusState == .editing {
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
                                        if searchType == .exact {
                                            coordinator.push(.exactCamera(searchKeyword: keyword))
                                        } else {
                                            coordinator.push(.semanticCamera(searchKeyword: keyword))
                                        }
                                    },
                                    onTapDelete: { keyword in
                                        withAnimation(.easeInOut(duration: 0.05)) {
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
                                .accessibilityLabel("최근 탐색어 전체 삭제")
                                .accessibilityHint("최근 탐색어 목록을 초기화합니다.")
                                .accessibilityAddTraits(.isButton)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.top, 26)
                    } else {
                        VStack {
                            Spacer()
                                .frame(height: 147)
                            Text(.noRecentSearchesMessage)
                                .font(.bodyMedium16)
                                .foregroundStyle(.ffipGrayscale3)
                                .accessibilityLabel("최근 탐색어가 없습니다.")
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    isToolTipPresented = true
                }
            }
            searchText = ""
        }
        .onChange(of: isFocused) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    if isFocused {
                        focusState = .editing
                    }
                }
            }
        }
        .ffipSheet(isPresented: $isSheetPresented) {
            SearchTypeSelectionView(selectedType: $searchType, dismissAction: dismissFfipSheet)
        }
        .showFfipToastMessage(
            toastType: .check,
            toastTitle: String(localized: .searchModeUpdated),
            isToastVisible: $hasSearchTypeChanged
        )
    }
    
    private func dismissFfipSheet() {
        if isToolTipPresented { isToolTipPresented = false }

        withAnimation {
            isSheetPresented = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation {
                isToolTipPresented = true
            }
        }
        hasSearchTypeChanged = true
    }
}

// #Preview {
//    let coordinator = AppCoordinator()
//    SearchView(searchModel: SearchModel(recentSearchKeywords: ["ㅇㅇ"]))
//        .environment(coordinator)
// }
