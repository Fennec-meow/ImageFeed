//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Kira on 21.01.2025.
//

import Foundation
import SwiftKeychainWrapper

// MARK: - OAuth2Service

final class OAuth2Service {
    
    // MARK: Singletone
    
    static let shared = OAuth2Service()
    private init() {}
    
    // MARK: URLSession
    
    // Объявляем и инициализируем переменную URLSession.
    private let urlSession = URLSession.shared
    
    // MARK: Private Property
    
    private(set) var authToken: String? {
        get {
            return SwiftKeychainWrapper().getToken()
        }
        set {
            SwiftKeychainWrapper().setToken(token: newValue)
        }
    }
    
    // Переменная для хранения указателя на последнюю созданную задачу. Если активных задач нет, то значение будет nil.
    private var task: URLSessionTask?
    
    // Переменная для хранения значения code, которое было передано в последнем созданном запросе.
    private var lastCode: String?
    
    // MARK: OAuthError
    
    private enum OAuthError: Error {
        case codeError, decodeError
    }
}

// MARK: - Creating an authentication token url

private extension OAuth2Service {
    func authTokenRequest(code: String) -> URLRequest? {
        let urlString = Constants.unsplashTokenURLString
        var components = URLComponents(string: urlString)
        
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = components?.url else {
            print("authTokenRequest: не удалось создать URL-адрес.\n") // Принт ошибки создания URL
            fatalError("Failed to create URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        print("authTokenRequest: создан запрос токена аутентификации: \(request).\n") // Принт созданного запроса
        return request
    }
}

// MARK: - Extracting the authentication token

extension OAuth2Service {
    func fetchOAuthToken(_ code: String, completion: @escaping(Result<String, Error>) -> Void) {
        assert(Thread.isMainThread) // Проверка на главный поток
        print("fetchOAuthToken: вызывается с помощью кода: \(code).\n") // Принт вызова функции
        
        // Если существует активная задача
        if lastCode == code {
            print("fetchOAuthToken: последний код совпадает, завершение функции.\n") // Принт завершения
            return
        }
        
        task?.cancel()
        lastCode = code // Сохраняем текущий код
        
        print("fetchOAuthToken: последний код не совпадает, возвращается ошибка.\n") // Принт ошибки
        completion(.failure(OAuthError.codeError))
        
        // Формируем запрос
        guard let request = authTokenRequest(code: code) else { return }
        print("fetchOAuthToken: не удалось создать запрос.\n") // Принт неудачи
        
        // Создаём задачу
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    self.authToken = authToken
                    print("fetchOAuthToken: успешно получен токен аутентификации: \(authToken).\n") // Принт успешного получения токена
                    completion(.success(authToken))
                case .failure(let error):
                    self.lastCode = nil
                    print("fetchOAuthToken: ошибка при получении токена аутентификации: \(error.localizedDescription).\n") // Принт ошибки
                    completion(.failure(error))
                }
                // Сброс состояния
                self.task = nil
                self.lastCode = nil
            }
        }
        self.task = task // Сохраняем текущую задачу
        print("fetchOAuthToken: запуск задачи для получения токена аутентификации.\n") // Принт начала задачи
        task.resume() // Запускаем задачу
    }
}
