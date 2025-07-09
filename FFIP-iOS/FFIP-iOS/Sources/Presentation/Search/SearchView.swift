//
//  SearchView.swift
//  FFIP-iOS
//
//  Created by mini on 7/8/25.
//

import SwiftUI

struct SearchView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Bindable var searchModel: SearchModel

    var body: some View {
        VStack {
            Button {
                coordinator.push(.camera)
            } label: {
                Text("Push camera view")
            }
        }
    }
}

#Preview {
    SearchView(searchModel: SearchModel())
}
