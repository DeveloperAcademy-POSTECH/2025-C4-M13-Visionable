//
//  FfipSheet.swift
//  FFIP-iOS
//
//  Created by mini on 7/15/25.
//

import SwiftUI

enum FfipSearchMode: String, CaseIterable {
    case designated = "지정 탐색"
    case related = "연관 탐색"
}

struct FfipSheet: View {
    @Binding var selectedMode: FfipSearchMode
    let onSelect: (FfipSearchMode) -> Void

    var body: some View {
        VStack(spacing: 32) {            
            Capsule()
                .fill(.ffipGrayscale4)
                .frame(width: 49, height: 4)
                .padding(.top, 6)
            
            Text("탐색 모드 선택")
                .font(.titleBold20)
                .foregroundStyle(.ffipGrayscale1)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                ForEach(FfipSearchMode.allCases, id: \.self) { mode in
                    HStack {
                        Text(mode.rawValue)
                            .font(.bodyMedium16)
                            .foregroundColor(.ffipGrayscale2)
                        
                        if mode == .related {
                            Image(.icnAImark)
                        }
                        
                        Spacer()
                        
                        Image(mode == selectedMode ? .icnCheckEnabled : .icnCheckDisabled)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelect(mode)
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .background(.ffipBackground2Modal)
        .ignoresSafeArea(edges: .bottom)
        .cornerRadius(24)
    }
}

#Preview {
    FfipSheet(selectedMode: .constant(.designated), onSelect: {_ in })
}
