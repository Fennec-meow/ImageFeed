//
//  Profile.swift
//  ImageFeed
//
//  Created by Kira on 03.03.2025.
//

import Foundation

struct Profile {
    let userName: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(profileResult: ProfileResult) {
        self.userName = profileResult.username
        self.name = [profileResult.firstName, profileResult.lastName].compactMap { $0 }.joined(separator: " ")
        self.loginName = "@\(profileResult.username)"
        self.bio = profileResult.bio
    }
}
