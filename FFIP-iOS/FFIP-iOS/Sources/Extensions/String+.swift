//
//  String+.swift
//  FFIP-iOS
//
//  Created by SeanCho on 7/23/25.
//

import SwiftUI

extension String {
    func asHighlight(
        highlightedString: String,
        highlightColor: Color
    ) -> AttributedString {
        var attributed = AttributedString(self)
        if let range = attributed.range(of: highlightedString) {
            attributed[range].foregroundColor = highlightColor
        }
        
        return attributed
    }
}
