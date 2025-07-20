//
//  FFIPWidgetBundle.swift
//  FFIPWidget
//
//  Created by mini on 7/17/25.
//

import WidgetKit
import SwiftUI

@main
struct FFIPWidgetBundle: WidgetBundle {
    var body: some Widget {
        FFIPExactSearchWidget()
        FFIPSemanticSearchWidget()
    }
}
