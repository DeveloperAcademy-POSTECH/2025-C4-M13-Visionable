//
//  SearchView.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

enum SearchType: String, CaseIterable, Identifiable {
    case keyword
    case semantic
    
    var id: String { rawValue }
    
    var title: LocalizedStringResource {
        switch self {
        case .keyword: return .exactSearch
        case .semantic: return .semanticSearch
        }
    }
    
    var placeholder: LocalizedStringResource {
        switch self {
        case .keyword: return .exactSearchPlaceholder
        case .semantic: return .semantictSearchPlaceholder
        }
    }
    
    var tagIcon: ImageResource? {
        switch self {
        case .keyword:
            return nil
        case .semantic:
            return .icnAImark
        }
    }
}

struct SearchView: View {
    private enum SearchFocusState {
        case home
        case editing
    }
    
    @Environment(AppCoordinator.self) private var coordinator
    @Bindable var searchModel: SearchModel
    @State private var selectedSearchType: SearchType = .keyword
    @FocusState private var isFocused: Bool
    @State private var isSheetPresented: Bool = false
    @State private var focusState: SearchFocusState = .home
    @State private var searchText: String = ""
    @State private var hasSearchTypeChanged: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                if focusState == .home {
                    Button {
                        isSheetPresented.toggle()
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
                    .tint(.black)
                    .padding(.top, 90)
                    .opacity(isFocused ? 0 : 1)
                }
                
                FfipSearchTextField(
                    text: $searchText,
                    isFocused: focusState == .editing,
                    placeholder: String(localized: selectedSearchType.placeholder),
                    onTapBackButton: {
                        withAnimation(.easeOut(duration: 0.15)) {
                            isFocused = false
                        }
                    },
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
                        if !searchModel.recentSearchKeywords.isEmpty {
                            Text(.recentSearchTitle)
                                .font(.caption)
                                .padding(.top, 20)
                        }
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
            
            if hasSearchTypeChanged {
                FfipToastMessage(toastType: .check, toastTitle: String(localized: .searchModeUpdated))
                    .padding(.bottom, 32)
                    .ignoresSafeArea(.all, edges: .bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: hasSearchTypeChanged)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.15)) {
                isFocused = false
            }
            isSheetPresented = false
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
        .onChange(of: selectedSearchType) {
            isSheetPresented = false
            hasSearchTypeChanged = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    hasSearchTypeChanged = false
                }
            }
        }
        .ffipSheet(isPresented: $isSheetPresented) {
            SearchTypeSelectionView(selectedType: $selectedSearchType)}
    }
}

// #Preview {
//    let coordinator = AppCoordinator()
//    SearchView(searchModel: SearchModel(recentSearchKeywords: ["ㅇㅇ"]))
//        .environment(coordinator)
// }
