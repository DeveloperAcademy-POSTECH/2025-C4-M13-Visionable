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
                OnboardingUpperContentView(
                    type: steps[currentStepIndex],
                    typingText: steps[currentStepIndex].textFieldFilledKeyword
                )
                
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
                        coordinator.popToRoot()
                    } else {
                        currentStepIndex += 1
                        triggerHapticFeedback()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - 온보딩 상단 탭바와 별도로 애니메이션을 포함하는 목업 화면
struct OnboardingUpperContentView: View {
    @State private var currentImageResourceIndex = 0
    @State private var isTextFiledVisible: Bool = false
    @State private var onboardingText = ""
    @State private var isImageTimerRunning = false
    @State private var onChangeTask: Task<Void, Never>?
    
    let type: FfipOnboardingType
    let typingText: String?
    private let imageInterval: TimeInterval = 1.0
    private let typingSpeed: Duration = .milliseconds(100)
    
    var body: some View {
        ZStack {
            Color.ffipGrayscale5.ignoresSafeArea()
            
            VStack {
                Spacer(minLength: 48)
                Image(type.onboardingImageResource[currentImageResourceIndex])
                    .transition(type == .first ? .scale : .opacity)
            }
            
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 50)
                    .fill(.ffipGrayscale5NoDark)
                    .frame(height: 50)
                    .overlay(
                        HStack(spacing: 0) {
                            Text(onboardingText)
                                .foregroundStyle(.ffipGrayscale1NoDark)
                                .font(.labelMedium14)
                                .padding(.leading, 18)
                            Spacer()
                        }
                    )
                
                Image(.icnSettingsVoiceNoDark)
                    .frame(width: 50, height: 50)
                    .tint(.ffipGrayscale1)
                    .background(Circle().fill(.ffipGrayscale5NoDark))
            }
            .padding(.top, 80)
            .padding(.leading, 38)
            .padding(.trailing, 28)
            .shadow(color: .black.opacity(0.21), radius: 24)
            .opacity(isTextFiledVisible ? 1 : 0)
        }
        .onChange(of: type) {
            handleOnboardingAnimation()
        }
        .onAppear {
            handleOnboardingAnimation()
        }
    }
    
    private func startTypingAnimation() {
        isTextFiledVisible = true
        onboardingText = ""
        guard let typingText else { return }

        Task {
            for char in typingText {
                onboardingText.append(char)
                try? await Task.sleep(for: typingSpeed)
            }
        }
    }
    
    private func handleOnboardingAnimation() {
        onChangeTask?.cancel()
        currentImageResourceIndex = 0
        isTextFiledVisible = false
        onChangeTask = Task {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.5)) {
                currentImageResourceIndex += 1
                if type != .first {
                    startTypingAnimation()
                } else {
                    triggerHapticFeedback()
                }
            }
        }
    }
}

// MARK: - 온보딩 하단 탭바에 들어가는 화면
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
                .foregroundStyle(.ffipGrayscale4)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, type == .third ? 19 : 39)
    }
}

// #Preview {
//    OnboardingView()
//        .environment(AppCoordinator())
// }

