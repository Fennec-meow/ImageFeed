//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Kira on 21.01.2025.
//

import Foundation

// MARK: OAuthTokenResponseBody

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope = "scope"
        case createdAt = "created_at"
    }
}
