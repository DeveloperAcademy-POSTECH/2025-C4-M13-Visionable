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
        .onChange(of: searchType) {
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
        .ffipSheet(isPresented: $isSheetPresented) {
            SearchTypeSelectionView(selectedType: $searchType)
        }
        .showFfipToastMessage(
            toastType: .check,
            toastTitle: String(localized: .searchModeUpdated),
            isToastVisible: $hasSearchTypeChanged
        )
    }
}

// #Preview {
//    let coordinator = AppCoordinator()
//    SearchView(searchModel: SearchModel(recentSearchKeywords: ["ㅇㅇ"]))
//        .environment(coordinator)
// }
