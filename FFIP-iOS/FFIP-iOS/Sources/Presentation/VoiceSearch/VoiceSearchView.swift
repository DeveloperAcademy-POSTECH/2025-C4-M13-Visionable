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
        Text(.helloWorld)
    }
}

#Preview {
    VoiceSearchView(voiceSearchModel: VoiceSearchModel())
}
