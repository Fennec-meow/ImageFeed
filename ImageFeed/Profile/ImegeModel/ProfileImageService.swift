//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Kira on 04.03.2025.
//

import Foundation

// MARK: - class ProfileImageService

final class ProfileImageService {
    
    // MARK: синглтон
    
    static let shared = ProfileImageService()
    private init() {}
    
    // MARK: URLSession
    
    private let urlSession = URLSession.shared
    
    // MARK: avatarURL
    
    private(set) var avatarURL: String?
    
    private var task: URLSessionTask?
    
    private var lastToken: String?
    
    private var userResultURL: String? = nil
    
    // MARK: Notification
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    // MARK: completeFetch
    
    private func completeFetch(for username: String) -> URLRequest {
        guard let url = URL(string: "https://api.unsplash.com/users/" + username) else {
            preconditionFailure("Failed to create url")
        }
        var request = URLRequest(url: url)
        guard let token = OAuth2Service.shared.authToken else {
            preconditionFailure("Failed with token")
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        print("completeFetch: создан запрос для пользователя \(username) с токеном. \n") // Принт созданного запроса
        return request
    }
    
    //MARK: fetchProfileImageURL
    
    func fetchProfileImageURL(_ username: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        print("fetchProfileImageURL: вызывается для пользователя \(username).\n") // Принт вызова функции
        
        let request = completeFetch(for: username)
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            DispatchQueue.main.async { return }
            switch result {
            case .success(let json):
                DispatchQueue.main.async {
                    self.userResultURL = json.profileImage.small
                    print("fetchProfileImageURL: успешно получен URL изображения профиля: \(json.profileImage.small).\n") // Принт успешного получения URL
                    completion(.success(json.profileImage.small))
                }
            case .failure(let error):
                print("fetchProfileImageURL: ошибка при получении изображения профиля: \(error.localizedDescription).\n") // Принт ошибки
                completion(.failure(error))
            }
            
            self.task = nil
        }
        self.task = task
        print("fetchProfileImageURL: запуск задачи для получения изображения профиля для пользователя \(username).\n") // Принт начала задачи
        task.resume()
    }
    
    func setAvatarUrlString(avatarUrl: String) {
        self.avatarURL = avatarUrl
        print("setAvatarUrlString: установлен URL аватара: \(avatarUrl).\n") // Принт установки URL аватара
    }
}
//    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
//        let request = completeFetch(for: username)
//        
////        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
//
//        let task = urlSession.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async { return }
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            guard let data = data else {
//                completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
//                return
//            }
//            do {
//                let urlString = try JSONDecoder().decode(String.self, from: data)
//                self.avatarURL = urlString
//                completion(.success(urlString))
//                NotificationCenter.default                                     // 1
//                    .post(                                                     // 2
//                        name: ProfileImageService.didChangeNotification,       // 3
//                        object: self,                                          // 4
//                        userInfo: ["URL": self.avatarURL ?? ""]) // 5
//            } catch {
//                completion(.failure(error))
//            }
//        }.resume() // Запускаем задачу
//    }

