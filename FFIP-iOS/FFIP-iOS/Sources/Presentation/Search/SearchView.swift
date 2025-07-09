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
        Text("Hello C4 !")
    }
}

#Preview {
    SearchView(searchModel: SearchModel())
}
