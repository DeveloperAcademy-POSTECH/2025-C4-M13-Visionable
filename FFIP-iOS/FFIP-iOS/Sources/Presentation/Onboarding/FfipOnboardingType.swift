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
            ".onboarding1Title"
        case .second:
            ".onboarding2Title"
        case .third:
            ".onboarding3Title"
        }
    }
    
    var badgeText: String? {
        switch self {
        case .third:
            ".aiBadge"
        default: nil
        }
    }

    var description: String {
        switch self {
        case .first:
            ".onboarding1Description"
        case .second:
            ".onboarding2Description"
        case .third:
            ".onboarding3Description"
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .first, .second:
            ".next"
        case .third:
            ".startExplore"
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
        case .second:
            ".onboarding2TextFieldKeyword"
        case .third:
            ".onboarding3TextFieldKeyword"
        default: nil
        }
    }
}
