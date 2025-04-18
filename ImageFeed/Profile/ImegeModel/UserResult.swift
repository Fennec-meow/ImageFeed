//
//  UserResult.swift
//  ImageFeed
//
//  Created by Kira on 04.03.2025.
//

import Foundation

// MARK: UserResult

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

// MARK: ProfileImage

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
    
    enum CodingKeys: String, CodingKey {
        case small = "small"
        case medium = "medium"
        case large = "large"
    }
}
