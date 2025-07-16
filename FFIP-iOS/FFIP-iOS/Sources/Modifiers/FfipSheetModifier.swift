//
//  FfipSheetModifier.swift
//  FFIP-iOS
//
//  Created by mini on 7/15/25.
//

import SwiftUI

struct FfipSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var selectedMode: FfipSearchMode

    @State private var offsetY: CGFloat = 0

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content

            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismiss()
                    }

                FfipSheet(selectedMode: $selectedMode) { mode in
                    selectedMode = mode
                    dismiss()
                }
                .offset(y: offsetY)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.height > 0 {
                                offsetY = value.translation.height
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > 100 {
                                dismiss()
                            } else {
                                withAnimation { offsetY = 0 }
                            }
                        }
                )
                .onAppear {
                    offsetY = 230
                    withAnimation { offsetY = 0 }
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }

    private func dismiss() {
        withAnimation {
            offsetY = 230
            isPresented = false
        }
    }
}

extension View {
    func ffipSheet(
        isPresented: Binding<Bool>,
        selectedMode: Binding<FfipSearchMode>
    ) -> some View {
        self.modifier(
            FfipSheetModifier(
                isPresented: isPresented,
                selectedMode: selectedMode
            )
        )
    }
}
