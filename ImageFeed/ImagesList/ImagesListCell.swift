//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Kira on 29.12.2024.
//

import UIKit

// MARK: - ImagesListCell

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
}
