//
//  Text+.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

extension Text {
    /// 특정 문자열을 다른 스타일로 꾸미는 함수
    static func styledText(
        fullText: String,
        highlightedText: String,
        baseColor: Color,
        baseFont: Font,
        highlightedColor: Color,
        highlightedFont: Font
    ) -> Text {
        let parts = fullText.components(separatedBy: highlightedText)
        var styled = Text("")
        
        for (index, partText) in parts.enumerated() {
            styled = styled + Text(partText)
                .foregroundStyle(baseColor)
                .font(baseFont)
            
            if index < parts.count - 1 {
                styled = styled + Text(highlightedText)
                    .foregroundStyle(highlightedColor)
                    .font(highlightedFont)
            }
        }

        return styled
    }
}
