//
//  FfipNavigationBar.swift
//  FFIP-iOS
//
//  Created by mini on 7/21/25.
//

import SwiftUI

struct FfipNavigationBar: View {
    private let leadingType: FfipNavigationBarLeadingType
    private let centerType: FfipNavigationBarCenterType
    private let trailingType: FfipNavigationBarTrailingType
    
    public init(
        leadingType: FfipNavigationBarLeadingType,
        centerType: FfipNavigationBarCenterType,
        trailingType: FfipNavigationBarTrailingType
    ) {
        self.leadingType = leadingType
        self.centerType = centerType
        self.trailingType = trailingType
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                navigationLeadingView()
                Spacer()
                navigationCenterView()
                Spacer()
                navigationTrailingView()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ffipBackground1Main)
        }
    }
}

// MARK: - View Builder
private extension FfipNavigationBar {
    @ViewBuilder
    private func navigationLeadingView() -> some View {
        switch leadingType {
        case .logo:
            Image(.logoFfip)
                .padding(.leading, 8)
        case .back(let action):
            Button(action: action) {
                Image(.icnNavBack)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
            }
        case .none:
            Spacer().frame(width: 20).opacity(0)
        }
    }
    
    @ViewBuilder
    private func navigationCenterView() -> some View {
        switch centerType {
        case .title(let title):
            Text(title)
                .font(.titleSemiBold16)
                .foregroundStyle(.ffipGrayscale1)
        case .none:
            Spacer().frame(width: 20).opacity(0)
        }
    }
    
    @ViewBuilder
    private func navigationTrailingView() -> some View {
        switch trailingType {
        case .grid(let action):
            Button(action: action) {
                Image(.icnGrid)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
            }
        case .none:
            Spacer().frame(width: 20).opacity(0)
        }
    }
}

// MARK: - Navigation Type
enum FfipNavigationBarLeadingType {
    case logo
    case back(action: () -> Void)
    case none
}

enum FfipNavigationBarCenterType {
    case title(title: String)
    case none
}

enum FfipNavigationBarTrailingType {
    case grid(action: () -> Void)
    case none
}

// #Preview {
//    FfipNavigationBar(
//        leadingType: .back(action: {}),
//        centerType: .title(title: "어쩌구검색어 텟스트"),
//        trailingType: .grid(action: {})
//    )
// }
