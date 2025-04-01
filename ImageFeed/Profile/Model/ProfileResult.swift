//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Kira on 03.03.2025.
//

import Foundation

// MARK: ProfileResult

struct ProfileResult: Codable {
    let id: String
    let username: String
    let name: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case id, username, name
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
}
