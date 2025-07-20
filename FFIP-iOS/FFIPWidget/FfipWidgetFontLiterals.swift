//
//  FfipWidgetFontLiterals.swift
//  FFIP-iOS
//
//  Created by mini on 7/17/25.
//

import SwiftUI

enum FontName: String {
    case pretendardSemiBold = "Pretendard-SemiBold"
}

extension Font {
    static let widgetSemiBold16: Font = .custom(FontName.pretendardSemiBold.rawValue, size: 16)
}
