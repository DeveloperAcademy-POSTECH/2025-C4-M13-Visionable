//
//  FfipOnboardingType.swift
//  FFIP-iOS
//
//  Created by mini on 7/22/25.
//

import SwiftUI

enum FfipOnboardingType: CaseIterable {
    case first, second, third
    
    var title: String {
        switch self {
        case .first:
            String(localized: .onboarding1Title)
        case .second:
            String(localized: .onboarding2Title)
        case .third:
            String(localized: .onboarding3Title)
        }
    }
    
    var titleAccessibilityLabel: String {
        switch self {
        case .first:
            String(localized: .VoiceOverLocalizable.onboarding1Title)
        case .second:
            String(localized: .VoiceOverLocalizable.onboarding2Title)
        case .third:
            String(localized: .VoiceOverLocalizable.onboarding3Title)
        }
    }
    
    var badgeText: String? {
        switch self {
        case .third:
            String(localized: .aiBadge)
        default: nil
        }
    }

    var description: String {
        switch self {
        case .first:
            String(localized: .onboarding1Description)
        case .second:
            String(localized: .onboarding2Description)
        case .third:
            String(localized: .onboarding3Description)
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .first, .second:
            String(localized: .next)
        case .third:
            String(localized: .startExplore)
        }
    }
    
    var buttonTitleAccessibilityLabel: String {
        switch self {
        case .first, .second:
            String(localized: .next)
        case .third:
            String(localized: .VoiceOverLocalizable.startExplore)
        }
    }
    
    var onboardingImageResource: [ImageResource] {
        switch self {
        case .first:
            [.onboardingBook, .onboardingBookFind]
        case .second:
            [.onboardingExact, .onboardingExactDimmed]
        case .third:
            [.onboardingSemantic, .onboardingSemanticDimmed]
        }
    }
    
    var textFieldFilledKeyword: String? {
        switch self {
        case .second: String(localized: .onboarding2TextFieldKeyword)
        case .third: String(localized: .onboarding3TextFieldKeyword)
        default: nil
        }
    }
}
