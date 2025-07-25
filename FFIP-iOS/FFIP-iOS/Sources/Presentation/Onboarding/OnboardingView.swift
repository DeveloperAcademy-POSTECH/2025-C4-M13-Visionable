//
//  OnboardingView.swift
//  FFIP-iOS
//
//  Created by mini on 7/22/25.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(AppCoordinator.self) private var coordinator

    @State private var currentStepIndex = 0
    private let steps = FfipOnboardingType.allCases
    
    var body: some View {
        ZStack {
            Color.ffipBackground1Main
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                OnboardingUpperContentView(type: steps[currentStepIndex])

                TabView(selection: $currentStepIndex) {
                    ForEach(steps.indices, id: \.self) { index in
                        VStack(spacing: 0) {
                            OnboardingBottomContentView(type: steps[index])
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStepIndex)
                .ignoresSafeArea()
                
                FfipPageControl(
                    totalCount: steps.count,
                    currentIndex: currentStepIndex
                )
                .padding(.bottom, 8)
                
                FfipButton(title: steps[currentStepIndex].buttonTitle) {
                    if currentStepIndex == 2 {
                        coordinator.push(.search)
                    } else {
                        currentStepIndex += 1
                    }
                }
            }
        }
    }
}

struct OnboardingUpperContentView: View {
    @State private var currentImageResourceIndex = 0
    
    let type: FfipOnboardingType
    let interval: TimeInterval = 2.0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.ffipGrayscale5.ignoresSafeArea()
            
            VStack {
                Spacer(minLength: 48)
                Image(type.onboardingImageResource[currentImageResourceIndex])
            }
            
        }
    }
}

struct OnboardingBottomContentView: View {
    let type: FfipOnboardingType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let badge = type.badgeText {
                Text(badge)
                    .font(.onboardingSemiBold12)
                    .foregroundColor(.ffipBackground1Main)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.ffipPointGreen1)
                    .cornerRadius(4)
            }
            
            Text(type.title)
                .font(.onboardingBold24)
                .multilineTextAlignment(.leading)
                .lineSpacing(8)
                .foregroundStyle(.ffipGrayscale1)
                .padding(.bottom, 10)
                .padding(.top, type == .third ? 16 : 0)
            
            Text(type.description)
                .font(.bodyMedium16)
                .multilineTextAlignment(.leading)
                .lineSpacing(8)
                .foregroundStyle(.ffipGrayscale3)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, type == .third ? 19 : 39)
    }
}

#Preview {
    OnboardingView()
        .environment(AppCoordinator())
}
