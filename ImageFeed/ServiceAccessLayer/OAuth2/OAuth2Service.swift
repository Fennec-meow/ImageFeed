//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Kira on 21.01.2025.
//

import Foundation

final class OAuth2Service {
    private let unsplashAuthorizeURLString = "https://unsplash.com/oauth/token"
    
    private enum OAuthError: Error {
        case codeError, decodeError
    }
    
    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: unsplashAuthorizeURLString)!
        var request = URLRequest(url: url)
        
        let payload: [String: String] = [
            "client_id": accessKey,
            "client_secret": secretKey,
            "redirect_uri": redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            if
                let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300
            {
                completion(.failure(OAuthError.codeError))
                return
            }
            
            guard let data else { return }
            
            do {
                let json = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                completion(.success(json.accessToken))
            } catch {
                completion(.failure(OAuthError.decodeError))
            }
        }
        
        task.resume()
    }
}
