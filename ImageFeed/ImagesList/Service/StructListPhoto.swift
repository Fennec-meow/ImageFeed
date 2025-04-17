//
//  StructListPhoto.swift
//  ImageFeed
//
//  Created by Kira on 31.03.2025.
//

import Foundation

// MARK: Photo

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

extension Photo {
    func withToggledLike() -> Photo {
        Photo(
            id: id,
            size: size,
            createdAt: createdAt,
            welcomeDescription: welcomeDescription,
            thumbImageURL: thumbImageURL,
            largeImageURL: largeImageURL,
            isLiked: !isLiked
        )
    }
}

struct Page: Equatable {
    let number: Int
    let perPage: Int
}

// MARK: UrlsResult

struct UrlsResult: Codable {
    let raw, full, regular, small: String
    let thumb: String
}

// MARK: LikeResult

struct LikeResult: Decodable {
    let photo: PhotoResult
}

// MARK: PhotoResult

struct PhotoResult: Decodable {
    let id: String
    let createdAt, updatedAt: String
    let width, height: Int
    let color, blurHash, welcomeDescription: String?
    let urls: UrlsResult
    let likedByUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width, height, color
        case blurHash = "blur_hash"
        case welcomeDescription = "description"
        case urls
        case likedByUser = "liked_by_user"
    }
}
