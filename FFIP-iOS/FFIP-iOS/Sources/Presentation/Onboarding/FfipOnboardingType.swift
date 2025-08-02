//
//  FfipOnboardingType.swift
//  FFIP-iOS
//
//  Created by mini on 7/22/25.
//

import SwiftUI

enum FfipOnboardingType: CaseIterable {
    case first, second
    
    var title: LocalizedStringResource {
        switch self {
        case .first:
            "빠르게 찾고 싶다면\n어디서든 하나, 둘, FF!p"
        case .second:
            "이름을 알고 있다면\nFF!p 지정 탐색"
        }
    }

    var description: LocalizedStringResource {
        switch self {
        case .first:
            "책 제목, 역 이름, 가게 간판\n이제는 3초도 찾아 헤매지 마세요."
        case .second:
            "찾는 단어만 정확히 입력하면\n실시간으로 찾아서 보여드려요."
        }
    }
    
    var buttonTitle: LocalizedStringResource {
        switch self {
        case .first:
            "다음"
        case .second:
            "탐색 시작하기"
        }
    }
    
    var onboardingImageResource: [ImageResource] {
        switch self {
        case .first:
            [.onboardingBook, .onboardingBookFind]
        case .second:
            [.onboardingExact, .onboardingExactDimmed]
        }
    }
    
    var textFieldFilledKeyword: LocalizedStringResource? {
        switch self {
        case .second:
            "어린 왕자"
        default: nil
        }
    }
}
