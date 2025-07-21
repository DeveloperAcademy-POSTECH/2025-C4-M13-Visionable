//
//  HFlowLayout.swift
//  FFIP-iOS
//
//  Created by Jamin on 7/21/25.
//

import SwiftUI

struct HFlowLayout: Layout {
    let spacing: CGFloat
    let lineSpacing: CGFloat

    init(
        spacing: CGFloat = 6,
        lineSpacing: CGFloat = 6
    ) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing
    }

    nonisolated func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var maxHeightInRow: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth {
                currentX = 0
                currentY += maxHeightInRow + lineSpacing
                maxHeightInRow = 0
            }

            maxHeightInRow = max(maxHeightInRow, size.height)
            currentX += size.width + spacing
        }
        return CGSize(width: maxWidth, height: currentY + maxHeightInRow)
    }

    nonisolated func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var maxHeightInRow: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(proposal)

            if currentX + size.width > bounds.width {
                currentX = 0
                currentY += maxHeightInRow + lineSpacing
                maxHeightInRow = 0
            }

            view.place(
                at: CGPoint(x: bounds.minX + currentX, y: bounds.minY + currentY),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )

            currentX += size.width + spacing
            maxHeightInRow = max(maxHeightInRow, size.height)
        }
    }
}
