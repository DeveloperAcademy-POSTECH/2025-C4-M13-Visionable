//
//  FfipToolTip.swift
//  FFIP-iOS
//
//  Created by mini on 7/15/25.
//

import SwiftUI

public enum FfipToolTipPosition {
    case top, bottom, leading, trailing
}

struct FfipToolTip: View {
    let message: String
    let position: FfipToolTipPosition
    
    var body: some View {
        switch position {
        case .top:
            VStack(spacing: 0) {
                Text(message)
                    .font(.captionMedium12)
                    .foregroundColor(.ffipBackground1Main)
                    .multilineTextAlignment(.leading)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.ffipGrayscale1)
                    )
                
                if position == .top {
                    Triangle()
                        .fill(.ffipGrayscale1)
                        .rotationEffect(.degrees(180))
                        .frame(width: 10, height: 6)
                }
            }
        case .bottom:
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    if position == .bottom {
                        Triangle()
                            .fill(.ffipGrayscale1)
                            .rotationEffect(.degrees(0))
                            .frame(width: 10, height: 6)
                    }
                    
                    Text(message)
                        .font(.captionMedium12)
                        .foregroundColor(.ffipBackground1Main)
                        .multilineTextAlignment(.leading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.ffipGrayscale1)
                        )
                }
            }
        case .leading:
            Text(message)
                .font(.captionMedium12)
                .foregroundColor(.ffipBackground1Main)
                .multilineTextAlignment(.leading)
                .padding(.vertical, 12)
                .padding(.leading, 14)
                .padding(.trailing, 16)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.ffipGrayscale1)
                )
                .overlay(
                    Triangle()
                        .fill(.ffipGrayscale1)
                        .rotationEffect(.degrees(90))
                        .frame(width: 10, height: 6)
                        .offset(x: 8)
                    ,
                    alignment: .trailing
                )
        case .trailing:
            Text(message)
                .font(.captionMedium12)
                .foregroundColor(.ffipBackground1Main)
                .multilineTextAlignment(.leading)
                .padding(.vertical, 12)
                .padding(.leading, 16)
                .padding(.trailing, 14)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.ffipGrayscale1)
                )
                .overlay(
                    Triangle()
                        .fill(.ffipGrayscale1)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 10, height: 6)
                        .offset(x: -8)
                    ,
                    alignment: .leading
                )
        }
    }
}

// MARK: - 꼬리 삼각형

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview
// #Preview {
//    VStack(spacing: 50) {
//        Text("Top")
//            .padding()
//            .background(Color.blue)
//            .cornerRadius(10)
//            .ffipToolTip(isToolTipVisible: .constant(true), message: "Top에 표시됩니다.", position: .top, spacing: 10)
//
//        Text("Bottom")
//            .padding()
//            .background(Color.green)
//            .cornerRadius(10)
//            .ffipToolTip(isToolTipVisible: .constant(true), message: "Bottom에 표시됩니다.", position: .bottom, spacing: 12)
//
//        Text("Leading")
//            .padding()
//            .background(Color.orange)
//            .cornerRadius(10)
//            .ffipToolTip(isToolTipVisible: .constant(true), message: "왼쪽에 표시됩니다.", position: .leading, spacing: 10)
//
//        Text("Trailing")
//            .padding()
//            .background(Color.purple)
//            .cornerRadius(10)
//            .ffipToolTip(isToolTipVisible: .constant(true), message: "입력한 텍스트와 연관된\n모든 항목을 탐색합니다.", position: .trailing, spacing: 12)
//    }
//    .padding()
// }
