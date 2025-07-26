//
//  ThumbnailCell.swift
//  FFIP-iOS
//
//  Created by mini on 7/26/25.
//

import UIKit

final class ThumbnailCell: UICollectionViewCell {
    
    private let thumbnailImage = UIImageView()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
        setupHierarchy()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions
extension ThumbnailCell {
    func configureCell(image: UIImage) {
        thumbnailImage.image = image
    }
}

// MARK: - Private Extensions
private extension ThumbnailCell {
    func setupStyle() {
        thumbnailImage.layer.cornerRadius = 4
    }
    
    func setupHierarchy() {
        contentView.addSubview(thumbnailImage)
    }
    
    func setupLayout() {
        thumbnailImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbnailImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            thumbnailImage.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            thumbnailImage.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
}
