//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Kira on 21.01.2025.
//

import Foundation

final class OAuth2Service {
    private enum OAuthError: Error {
        case codeError, decodeError
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        var components = URLComponents(string: "https://unsplash.com/oauth/token")!
        
        components.queryItems = [
                    URLQueryItem(name: "client_id", value: accessKey),
                    URLQueryItem(name: "client_secret", value: secretKey),
                    URLQueryItem(name: "redirect_uri", value: redirectURI),
                    URLQueryItem(name: "code", value: code),
                    URLQueryItem(name: "grant_type", value: "authorization_code")
                ]
        
        if let url = components.url {
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
                        
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print(error)
                    completion(.failure(error))
                    return
                }
                
                // Проверяем статус-код
                if let response = response as? HTTPURLResponse {
                    // Интерполяция должна работать правильно
                    print("HTTP Status Code: \(response.statusCode)")
                    
                    if response.statusCode < 200 || response.statusCode >= 300 {
                        // Печатаем содержимое ответа для дополнительной информации
                        if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                            print("Response Body: \(responseBody)")
                        }
                        completion(.failure(OAuthError.codeError))
                        return
                    }
                }
                
                guard let data = data else {
                    print("No data received")
                    completion(.failure(OAuthError.decodeError))
                    return
                }
                
                do {
                    let json = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(json.accessToken))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(OAuthError.decodeError))
                }
            }
            
            task.resume()
        }
    }
}
