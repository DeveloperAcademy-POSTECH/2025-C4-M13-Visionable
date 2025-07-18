//
//  FontLiterals.swift
//  FFIP-iOS
//
//  Created by mini on 7/15/25.
//

import SwiftUI

enum FontName: String {
    case pretendardBold = "Pretendard-Bold"
    case pretendardMedium = "Pretendard-Medium"
    case pretendardSemiBold = "Pretendard-SemiBold"
}

extension Font {
    // Title
    static let titleBold24: Font = .custom(FontName.pretendardBold.rawValue, size: 24)
    static let titleBold20: Font = .custom(FontName.pretendardBold.rawValue, size: 20)

    // Body
    static let bodyMedium16: Font = .custom(FontName.pretendardMedium.rawValue, size: 16)

    // Label
    static let labelMedium16: Font = .custom(FontName.pretendardMedium.rawValue, size: 16)
    static let labelMedium12: Font = .custom(FontName.pretendardMedium.rawValue, size: 12)

    // Caption
    static let captionSemiBold14: Font = .custom(FontName.pretendardSemiBold.rawValue, size: 14)
    static let captionMedium12: Font = .custom(FontName.pretendardMedium.rawValue, size: 12)
}
