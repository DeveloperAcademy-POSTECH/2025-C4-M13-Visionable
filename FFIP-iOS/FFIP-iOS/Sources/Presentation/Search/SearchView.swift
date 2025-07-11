//
//  SearchView.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

struct SearchView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Bindable var searchModel: SearchModel
    @FocusState private var isFocused: Bool
    
    @State private var showRecent = false
    @State private var showButton = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            if showButton {
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
                placeholder: String(localized: "searchPlaceholder"),
                text: $searchModel.searchKeyword,
                onVoiceSearch: {
                    coordinator.push(.voiceSearch)
                },
                onSubmit: {
                    searchModel.submitSearch()
                    coordinator.push(.camera)
                },
                onEmptySubmit: {
                    
                }
            )
            .focused($isFocused)
            .padding(.vertical, 12)
            
            if showRecent {
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
            Task {
                if isFocused {
                    withAnimation {
                        showButton = false
                    }
                    
                    try? await Task.sleep(nanoseconds: 250_000_000)
                    withAnimation {
                        showRecent = true
                    }
                    
                } else {
                    withAnimation {
                        showRecent = false
                    }
                    
                    try? await Task.sleep(nanoseconds: 250_000_000)
                    withAnimation {
                        showButton = true
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isFocused)
    }
}

#Preview {
    let coordinator = AppCoordinator()
    SearchView(searchModel: SearchModel())
        .environment(coordinator)
}
