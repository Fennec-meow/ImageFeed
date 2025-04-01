//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Kira on 21.01.2025.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

// MARK: - URLSession

extension URLSession {
    
    // MARK: func objectTask
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        
        let task = dataTask(with: request, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("objectTask: сеть: \(error.localizedDescription) \(request).\n")
                    
                    completion(.failure(error))
                    return
                }
                if let response = response as? HTTPURLResponse,
                   response.statusCode < 200 || response.statusCode > 299 {
                    print("objectTask: статус кода: \(response.statusCode) \(request).\n")
                    completion(.failure(NetworkError.urlSessionError))
                    return
                }
                guard let data else { return }
                
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    print("objectTask: декодированный объект: \(decodedObject) \(request).\n")
                    completion(.success(decodedObject))
                } catch {
                    print("objectTask: ошибка декодирования: \(error.localizedDescription) \(request).\n")
                    completion(.failure(NetworkError.urlSessionError))
                }
            }
        })
        
        return task
    }
    
    // MARK: func data
    
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        // Проверяем статус-код
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                print("data: получен ответ с кодом состояния: \(statusCode) \(request).\n") // Принт статуса ответа
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    print("data: ошибка HTTP с кодом состояния: \(statusCode) \(request).\n") // Принт ошибки статуса
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
                // Обработка ошибки
            } else if let error = error {
                print("data: ошибка сетевого запроса: \(error.localizedDescription) \(request).\n") // Принт сетевой ошибки
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("data: произошла неизвестная ошибка: \(request).\n") // Принт неизвестной ошибки
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        return task
    }
}
