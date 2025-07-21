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
    @State private var selectedSearchType: SearchType = .keyword
    @FocusState private var isFocused: Bool
    @State private var isSheetPresented: Bool = false
    @State private var focusState: SearchFocusState = .home
    @State private var searchText: String = ""
    @State private var hasSearchTypeChanged: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if focusState == .home {
                Button {
                    withAnimation {
                        isSheetPresented = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(selectedSearchType.title)
                            .font(.titleBold24)
                        Image(.icnKeyboardArrowDown)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20)
                    }
                }
                .tint(.ffipGrayscale1)
                .padding(.top, 90)
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
                    placeholder: String(localized: selectedSearchType.placeholder),
                    onVoiceSearch: {
                        coordinator.push(.voiceSearch)
                    },
                    onSubmit: {
                        searchModel.addRecentSearchKeyword(searchText)
                        if selectedSearchType == .keyword {
                            coordinator.push(.exactCamera(searchKeyword: searchText))
                        } else {
                            coordinator.push(.semanticCamera(searchKeyword: searchText))
                        }
                        
                    },
                    onEmptySubmit: { }
                )
                .focused($isFocused)
            }
            .padding(.vertical, 12)
            
            if focusState == .home {
                RecentSearchFlow(
                    keywords: searchModel.recentSearchKeywords,
                    onTap: { keyword in
                        searchModel.addRecentSearchKeyword(keyword)
                        if selectedSearchType == .keyword {
                            coordinator.push(.exactCamera(searchKeyword: searchText))
                        } else {
                            coordinator.push(.semanticCamera(searchKeyword: searchText))
                        }
                    },
                    onTapDelete: { keyword in
                        searchModel.deleteRecentSearchKeyword(keyword)
                    }
                )
            }
            
            if focusState == .editing {
                VStack(alignment: .leading, spacing: 20) {
                    if !searchModel.recentSearchKeywords.isEmpty {
                        Text(.recentSearchTitle)
                            .font(.caption)
                            .padding(.top, 20)
                        RecentSearchList(
                            keywords: searchModel.recentSearchKeywords,
                            onTap: { keyword in
                                searchModel.addRecentSearchKeyword(keyword)
                                if selectedSearchType == .keyword {
                                    coordinator.push(.exactCamera(searchKeyword: searchText))
                                } else {
                                    coordinator.push(.semanticCamera(searchKeyword: searchText))
                                }
                            },
                            onTapDelete: { keyword in
                                withAnimation(.easeInOut(duration: 0.05)) {
                                    searchModel.deleteRecentSearchKeyword(keyword)
                                }
                            }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }   
                }
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
                withAnimation(.easeInOut(duration: 0.15)) {
                    if isFocused {
                        focusState = .editing
                    }
                }
            }
        }
        .onChange(of: selectedSearchType) {
            withAnimation {
                isSheetPresented = false
            }
            hasSearchTypeChanged = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    hasSearchTypeChanged = false
                }
            }
        }
        .ffipSheet(isPresented: $isSheetPresented) {
            SearchTypeSelectionView(selectedType: $selectedSearchType)}
        .showFfipToastMessage(toastType: .check, toastTitle: String(localized: .searchModeUpdated), isToastVisible: $hasSearchTypeChanged)
    }
}

// #Preview {
//    let coordinator = AppCoordinator()
//    SearchView(searchModel: SearchModel(recentSearchKeywords: ["ㅇㅇ"]))
//        .environment(coordinator)
// }
