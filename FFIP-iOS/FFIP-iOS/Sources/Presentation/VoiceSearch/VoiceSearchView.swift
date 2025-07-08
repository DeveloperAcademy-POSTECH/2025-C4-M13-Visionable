//
//  VoiceSearchView.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

struct VoiceSearchView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Bindable var voiceSearchModel: VoiceSearchModel

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    VoiceSearchView(voiceSearchModel: VoiceSearchModel())
}
