//
//  ThumbnailCollectionViewController.swift
//  FFIP-iOS
//
//  Created by mini on 7/26/25.
//

import UIKit

final class ThumbnailCollectionViewController: UIViewController {
    private var isUserInteraction: Bool = false
    private var images = [UIImage]()
    private(set) var selectedIndex: Int = 0 {
        didSet {
            thumbnailCollectionView.reloadData()
            if !isUserInteraction {
                DispatchQueue.main.async {
                    self.scrollToSelected()
                }
            }
        }
    }
    private(set) var onSelect: ((Int) -> Void)?
    
    private lazy var thumbnailCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupRegisterCell()
        setupDelegate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyCenteredContentInset()
    }
    
    private func applyCenteredContentInset() {
        let cellWidth: CGFloat = 35
        let inset = (thumbnailCollectionView.bounds.width - cellWidth) / 2
        thumbnailCollectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

// MARK: - Extension Methods
extension ThumbnailCollectionViewController {
    func setupImages(_ images: [UIImage]) {
        self.images = images
    }
    
    func setupSelectedIndex(_ index: Int) {
        self.selectedIndex = index
    }
    
    func setOnSelect(_ handler: @escaping (Int) -> Void) {
        self.onSelect = handler
    }
    
    func stopScrolling() {
        print("멈춰!")
        thumbnailCollectionView.setContentOffset(thumbnailCollectionView.contentOffset, animated: false)
        thumbnailCollectionView.layer.removeAllAnimations()
    }
}

// MARK: - Private Extensions
private extension ThumbnailCollectionViewController {
    func setupStyle() {
        thumbnailCollectionView.backgroundColor = .ffipBackground1Main
        thumbnailCollectionView.showsHorizontalScrollIndicator = false
    }
    
    func setupHierarchy() {
        view.addSubview(thumbnailCollectionView)
    }
    
    func setupLayout() {
        thumbnailCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbnailCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            thumbnailCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            thumbnailCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            thumbnailCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setupRegisterCell() {
        thumbnailCollectionView.register(ThumbnailCell.self, forCellWithReuseIdentifier: ThumbnailCell.className)
    }
    
    func setupDelegate() {
        thumbnailCollectionView.delegate = self
        thumbnailCollectionView.dataSource = self
    }
    
    func scrollToSelected() {
        let indexPath = IndexPath(item: selectedIndex, section: 0)
        thumbnailCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

// MARK: - CollectionView Delegate
extension ThumbnailCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isUserInteraction = false
        selectedIndex = indexPath.item
        onSelect?(indexPath.item)
    }
}

// MARK: - CollectionView DataSource
extension ThumbnailCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailCell.className, for: indexPath) as? ThumbnailCell else { return UICollectionViewCell() }
        cell.configureCell(image: images[indexPath.item])
        return cell
    }
}

// MARK: - CollectionView Delegate Flow Layout

extension ThumbnailCollectionViewController: UICollectionViewDelegateFlowLayout {
    // sizeForItemAt: 각 Cell의 크기를 CGSize 형태로 return
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let selected = indexPath.item == selectedIndex
        return selected ? CGSize(width: 35, height: 35) : CGSize(width: 25, height: 35)
    }
    
    // minimumLineSpacing: Cell 들의 위, 아래 간격 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

extension ThumbnailCollectionViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isUserInteraction = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isUserInteraction else { return }
        
        let centerPoint = CGPoint(
            x: scrollView.bounds.midX,
            y: scrollView.bounds.midY
        )
        if let indexPath = thumbnailCollectionView.indexPathForItem(at: centerPoint) {
            if selectedIndex != indexPath.item {
                selectedIndex = indexPath.item
                onSelect?(indexPath.item)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
    }
}
