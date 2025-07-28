//
//  ThumbnailCollectionViewRepresentable.swift
//  FFIP-iOS
//
//  Created by mini on 7/26/25.
//

import SwiftUI

struct ThumbnailCollectionViewRepresentable: UIViewControllerRepresentable {
    var images: [UIImage]
    @Binding var selectedIndex: Int
    
    func makeUIViewController(context: Context) -> ThumbnailCollectionViewController {
        let vc = ThumbnailCollectionViewController()
        vc.setupImages(images)
        vc.setupSelectedIndex(selectedIndex)
        vc.setOnSelect { index in
            selectedIndex = index
        }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ThumbnailCollectionViewController, context: Context) {
        uiViewController.setupImages(images)
        uiViewController.setupSelectedIndex(selectedIndex)
    }
}
