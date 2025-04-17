//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Kira on 07.04.2025.
//

import Foundation

// MARK: - AuthHelperProtocol

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

// MARK: - AuthHelper

final class AuthHelper {
    
    // MARK: Public Property
    
    let configuration: AuthConfiguration

    // MARK: Constructor
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
}

// MARK: - Public Methods

 extension AuthHelper {
    
    func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.authURLString) else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        
        return urlComponents.url
    }
}

// MARK: - AuthHelperProtocol

extension AuthHelper: AuthHelperProtocol {
    
    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil }
        
        return URLRequest(url: url)
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
