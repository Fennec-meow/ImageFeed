//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Kira on 21.01.2025.
//

import Foundation

final class OAuth2Service {
    
    // MARK: - Синглтон
    
    static let shared = OAuth2Service()
    private init() {}
    
    // MARK: - OAuthError
    
    private enum OAuthError: Error {
        case codeError, decodeError
    }
    
    // MARK: - makeOAuthTokenRequest
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
        let baseURL = URL(string: "https://unsplash.com")
        let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"         // Используем знак ?, чтобы начать перечисление параметров запроса
            + "&&client_secret=\(Constants.secretKey)"    // Используем &&, чтобы добавить дополнительные параметры
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL                           // Опираемся на основной или базовый URL, которые содержат схему и имя хоста
        )!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    // MARK: - fetchOAuthToken
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        var components = URLComponents(string: "https://unsplash.com/oauth/token")!
        
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
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

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
}
