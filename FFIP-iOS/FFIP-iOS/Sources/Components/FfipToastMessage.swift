//
//  FfipToastMessage.swift
//  FFIP-iOS
//
//  Created by mini on 7/15/25.
//

import SwiftUI

// MARK: - Toast Message View
struct FfipToastMessage: View {
    private let ffipToastType: FfipToastType
    private let ffipToastTitle: String

    public init(
        toastType: FfipToastType,
        toastTitle: String
    ) {
        self.ffipToastType = toastType
        self.ffipToastTitle = toastTitle
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ffipToastType.iconImage

            Text(ffipToastTitle)
                .font(.captionSemiBold14)
                .foregroundColor(.ffipGrayScaleDefault2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ffipBackground3Pop)
        .cornerRadius(100)
    }
}

// MARK: - Toast Type Enum
public enum FfipToastType {
    case warning, check
    
    var iconImage: Image {
        switch self {
        case .warning: return Image(.icnToastWarning)
        case .check: return Image(.icnToastChecking)
        }
    }
}

// #Preview {
//    FfipToastMessage(toastType: .check, toastTitle: "텍스트가 들어갑니다.")
//    FfipToastMessage(toastType: .warning, toastTitle: "FFIP! 감지가 제한된 탐색어입니다.")
// }
