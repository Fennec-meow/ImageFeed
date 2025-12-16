//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Kira on 29.12.2024.
//

import UIKit

// MARK: - ImagesListCellDelegate

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

// MARK: - ImagesListCell

final class ImagesListCell: UITableViewCell {
    
    // MARK: UI Components
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    // MARK: Public Properties
    
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    var imageUrl: URL?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil // Устанавливаем изображение как nil, чтобы избежать отображения предыдущего изображения
    }
}

// MARK: - Private Methods

private extension ImagesListCell {
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
        self.accessibilityIdentifier = "like_button_on"
    }
}
