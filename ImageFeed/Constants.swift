//
//  Constants.swift
//  ImageFeed
//
//  Created by Kira on 20.01.2025.
//

import Foundation

enum Constants {
    static let accessKey = "F9m5lcPo6uJuYbyngJGb_7qqdOvgPuJN8jjDSnlV8RE"
    static let secretKey = "aMsHV4IoKIOr-gFXW7ErR7TDJL4NEAAf20H6DLM9ACk"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
    
    // MARK: - AuthorizeURL
    
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let unsplashTokenURLString = "https://unsplash.com/oauth/token"

    static let baseURL = "https://api.unsplash.com/me"
}

