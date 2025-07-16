//
//  ContentView.swift
//  FFIP-iOS
//
//  Created by mini on 7/15/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showToast: Bool = false
    @State private var isSheetPresented = false
    @State private var selectedMode: FfipSearchMode = .designated
    
    var body: some View {
        ZStack {
            VStack {
                Button("Show toast") {
                    showToast = true
                }
                Button("Show sheet") {
                    isSheetPresented = true
                }
            }
            
        }
        .showFfipToastMessage(toastType: .check, toastTitle: "저장완료이다 이놈들아!", isToastVisible: $showToast)
        .ffipSheet(isPresented: $isSheetPresented, selectedMode: $selectedMode)
    }
}

#Preview {
    ContentView()
}
