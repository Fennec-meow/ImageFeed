//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Kira on 28.02.2025.
//

import Foundation

// MARK: - class ProfileService

final class ProfileService {
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    
    private var lastToken: String?
    
    
    // MARK: синглтон
    
    static let shared = ProfileService()
    private init() {}
    
    // MARK: set profile
    
    private(set) var profile: Profile?
    
    // MARK: createRequest
    
    private func createRequest(with token: String) -> URLRequest {
        var request = URLRequest(url: URL(string: Constants.baseURL) ?? URL(fileURLWithPath: ""))
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        print("createRequest: создан запрос с токеном: \(token).\n") // Принт созданного запроса
        return request
    }
    
    // MARK: fetchProfile
    
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
//
//        urlSession.dataTask(with: request) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let data = data else {
//                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
//                return
//            }
//
//            do {
//                let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
//                let profile = Profile(profileResult: profileResult)
//                ProfileImageService.shared.fetchProfileImageURL(username: profile.loginName) { _ in }
//                completion(.success(profile))
//            } catch {
//                completion(.failure(error))
//            }
//        }.resume() // Запускаем задачу/

