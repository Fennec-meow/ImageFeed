//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Kira on 24.03.2025.
//

import Foundation
import UIKit

// MARK: - ImagesListViewController

final class ImagesListService {
    
    // MARK: Singletone
    
    static let shared = ImagesListService()
    //    private init() {}
    
    // MARK: Notification
    
    static let didChangeNotification = NotificationConstants.didChangeNotification
    
    // MARK: Public Property
    
    var photosPerPage = 10
    
    // MARK: Private Property
    
    private let notificationCenter = NotificationCenter.default
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Page?
    private var loadingPage: Page?
    
    private let tokenStorage = SwiftKeychainWrapper()
    private var lastToken: String?
    
    private lazy var dateFormatter: ISO8601DateFormatter = {
        return ISO8601DateFormatter()
    }()
}

// MARK: - Public Methods

extension ImagesListService {
    func fetchPhotosNextPage() {
        let nextPage: Page
        if let lastLoadedPage = lastLoadedPage {
            nextPage = Page(number: lastLoadedPage.number + 1, perPage: 10)
        }
        else {
            nextPage = Page(number: 1, perPage: 10)
        }
        
        // Уже выполняется выборка для данного authToken
        guard task == nil || self.loadingPage != nextPage else { return }
        // В случае, если выполняется задание для другого токена - отмените его
        task?.cancel()
        // Запомните страницу, чтобы предотвратить двойную загрузку
        self.loadingPage = nextPage
        
        let request = photosRequest(page: nextPage.number, perPage: nextPage.perPage)
        let task = urlSession.objectTask(for: request, completion: { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            
            self.task = nil
            
            guard case .success(let photosResult) = result else {
                // Ничего не делайте, если пользователь прокрутит страницу вниз, будет выполнен ещё один запрос
                return
            }
            
            let photos = photosResult.map { photoResult in
                Photo(
                    id: photoResult.id,
                    size: CGSize(width: photoResult.width, height: photoResult.height),
                    createdAt: self.date(from: photoResult.createdAt),
                    welcomeDescription: photoResult.welcomeDescription,
                    thumbImageURL: photoResult.urls.thumb,
                    largeImageURL: photoResult.urls.full,
                    isLiked: photoResult.likedByUser
                )}
            
            self.photos += photos
            self.lastLoadedPage = nextPage
            self.notificationCenter.post(name: Self.didChangeNotification, object: self)
        })
        
        task.resume()
        self.task = task
    }
    
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        enum LikeError: Error {
            case photoNotFound
        }
        let request = isLike ? likeRequest(photoId: photoId) : unlikeRequest(photoId: photoId)
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<LikeResult, Error>) in
            guard let self else { return }
            switch result {
            case .success:
                // Поиск индекса элемента
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    // Текущий элемент
                    let photo = self.photos[index]
                    // Копия элемента с инвертированным значением isLiked.
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    // Заменяем элемент в массиве.
                    photos[index] = newPhoto
                    completion(.success(()))
                } else {
                    completion(.failure(LikeError.photoNotFound))
                }
            case .failure(let error):
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

// MARK: - Private Methods

private extension ImagesListService {
    func photosRequest(page: Int, perPage: Int) -> URLRequest {
        makeRequest(path: "/photos?page=\(page)&&per_page=\(perPage)")
    }
    
    func makeRequest(
        path: String,
        httpMethod: String = HttpMethodConstants.httpMethodGET,
        baseURL: URL = URL(string: UrlConstants.baseURL)!
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httpMethod
        if let bearerToken = tokenStorage.getToken() {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: HttpMethodConstants.forHTTPHeaderField)
        }
        return request
    }
    
    func date(from string: String) -> Date? {
        dateFormatter.date(from: string)
    }
    
    func likeRequest(photoId: String) -> URLRequest {
        makeRequest(
            path: "/photos/\(photoId)/like",
            httpMethod: HttpMethodConstants.httpMethodPOST
        )
    }
    
    func unlikeRequest(photoId: String) -> URLRequest {
        makeRequest(
            path: "/photos/\(photoId)/like",
            httpMethod: HttpMethodConstants.httpMethodDELETE
        )
    }
    
    func getLargeImageCellURL(indexPath: IndexPath) -> URL {
        let stringUrl = photos[indexPath.row].largeImageURL
        guard let url = URL(string: stringUrl) else { fatalError("Don't have URL for large photo")}
        return url
    }
}

// MARK: - Constants

private extension ImagesListService {
    
    // MARK: NotificationConstants
    
    enum NotificationConstants {
        static let didChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    }
    
    // MARK: HttpMethodConstants
    
    enum HttpMethodConstants {
        static let httpMethodGET = "GET"
        static let httpMethodPOST = "POST"
        static let httpMethodDELETE = "DELETE"
        static let forHTTPHeaderField = "Authorization"
    }
    
    // MARK: UrlConstants
    
    enum UrlConstants {
        static let urlComponentsPath = "/oauth/authorize/native"
        static let baseURL = "https://api.unsplash.com"
    }
    
    // MARK: StringConstants
    
    enum StringConstants {
        static let codeItem = "code"
    }
}
