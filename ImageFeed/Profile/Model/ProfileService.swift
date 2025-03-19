//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Kira on 28.02.2025.
//

import Foundation

// MARK: - ProfileService

final class ProfileService {
    
    // MARK: Singletone
    
    static let shared = ProfileService()
    private init() {}
    
    // MARK: URLSession
    
    private let urlSession = URLSession.shared
    
    // MARK: Private Property
    
    private(set) var profile: Profile?
    private var task: URLSessionTask?
    private var lastToken: String?
    
}

// MARK: - fetchProfile

extension ProfileService {
    func fetchProfile(_ token: String, completion: @escaping(Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        print("fetchProfile: вызывается с токеном: \(token).\n") // Принт вызова функции
        
        // Если существует активная задача
        if lastToken == token  {
            print("fetchProfile: последний токен совпадает, завершение функции.\n") // Принт завершения
            return
        }
        
        task?.cancel()
        lastToken = token // Сохраняем текущий код
        
        let request = createRequest(with: token)
        
        let task = urlSession.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let json):
                let profileResult = ProfileResult(
                    id: json.id,
                    username: json.username,
                    name: json.name,
                    firstName: json.firstName,
                    lastName: json.lastName,
                    bio: json.bio ?? "")
                let profile = Profile(profileResult: profileResult)
                self.profile = profile
                print("fetchProfile: успешно получен профиль: \(profile).\n") // Принт успешного получения профиля
                completion(.success(profile))
            case .failure(let error):
                print("fetchProfile: ошибка при получении профиля: \(error.localizedDescription).\n") // Принт ошибки
                completion(.failure(error))
            }
            self.task = nil
            if case let .failure(error) = result {
                self.lastToken = nil
                print("fetchProfile: сброс последнего токена из-за ошибки: \(error.localizedDescription).\n") // Принт сброса токена
            }
        }
        self.task = task
        print("fetchProfile: запуск задачи для получения профиля.\n") // Принт начала задачи
        task.resume()
    }
}

// MARK: - createRequest

private extension ProfileService {
    func createRequest(with token: String) -> URLRequest {
        var request = URLRequest(url: URL(string: Constants.baseURL) ?? URL(fileURLWithPath: ""))
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        print("createRequest: создан запрос с токеном: \(token).\n") // Принт созданного запроса
        return request
    }
}

