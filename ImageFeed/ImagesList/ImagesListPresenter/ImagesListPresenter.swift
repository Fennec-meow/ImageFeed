//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Kira on 08.04.2025.
//

import Foundation
import UIKit

// MARK: - ImagesListPresenterProtocol

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    
    func largeImageURL(for index: Int) -> URL?
    func photo(for index: Int) -> Photo?
    
    func numberOfRowsInSection() -> Int
    func loadNextPhotos(for index: Int)
    func didTapLike(for row: Int)
}

// MARK: - ImagesListPresenter

final class ImagesListPresenter {
    
    // MARK: Public Properties
    
    weak var view: ImagesListViewControllerProtocol?
    
    // MARK: Private Properties
    
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    private let notificationCenter = NotificationCenter.default
    private var imagesListServiceObserver: NSObjectProtocol?
}

// MARK: - Private Methods

private extension ImagesListPresenter {
    
    func showError(_ message: String) {
        view?.showError(message)
    }
    
    func tableViewAnimated() {
        let oldCount = photos.count
        self.photos = imagesListService.photos // Обновите массив фотографий
        let newCount = photos.count
        
        print("updateTableViewAnimated: старая количество фотографий: \(oldCount), новая количество: \(newCount)\n")
        
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }
    
    func imagesFetchPhotos() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func setupImagesListServiceObserver() {
        imagesListServiceObserver = notificationCenter.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            tableViewAnimated()
            print("setupImagesListServiceObserver: наблюдатель установлен для изменения фотографий.\n")
        }
    }
}

// MARK: - ImagesListPresenterProtocol

extension ImagesListPresenter: ImagesListPresenterProtocol {
    
    func viewDidLoad() {
        imagesFetchPhotos()
        setupImagesListServiceObserver()
    }
    
    func photo(for index: Int) -> Photo? {
        if index < photos.count {
            let photo = photos[index]
            return photo
        }
        return nil
    }
    
    func largeImageURL(for index: Int) -> URL? {
        let photo = photos[index]
        // Проверка URL перед передачей
        let url = URL(string: photo.largeImageURL)
        return url
    }
    
    func numberOfRowsInSection() -> Int {
        print("Number of rows: \(photos.count)") // Отладочное сообщение
        return photos.count
    }
    
    func loadNextPhotos(for index: Int) {
        if index == photos.count - 1 {
            imagesFetchPhotos()
        }
    }
    
    func didTapLike(for row: Int) {
        var photo = photos[row]
        
        view?.showProgressHUD()
        photo.isLiked.toggle() // Меняем состояние лайка
        
        print("imageListCellDidTapLike: пользователь нажал на кнопку лайка для фотографии с id: \(photo.id)\n")
        
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            
            guard let self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success:
                    print("imageListCellDidTapLike: лайк успешно обновлен для фотографии с id: \(photo.id)\n")
                    
                    // Обновляем состояние локально
                    photos[row].isLiked = photo.isLiked
                    view?.reloadData()
                case .failure:
                    print("imageListCellDidTapLike: не удалось обновить лайк для фотографии с id: \(photo.id)\n") // Обработка ошибки
                    self.showError("Не удалось обновить состояние лайка. Попробуйте еще раз.") // Вызов ошибки
                }
                view?.hideProgressHUD()
            }
        }
    }
}

