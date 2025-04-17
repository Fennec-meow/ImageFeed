//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Kira on 15.04.2025.
//

//import ImageFeed
import Foundation
final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    
    var viewDidLoadCalled: Bool = false
    var loadNextPhotosCalled: Bool = false // добавили флаг
    var photoReturned: Bool = false
    
    var photos: [Photo] = [
        .init(id: "1", size: .init(width: 20, height: 20), createdAt: Date(), welcomeDescription: "1", thumbImageURL: "1", largeImageURL: "1", isLiked: true),
        .init(id: "2", size: .init(width: 40, height: 40), createdAt: Date(), welcomeDescription: "2", thumbImageURL: "2", largeImageURL: "2", isLiked: false)
    ]
    
    func viewDidLoad() {
        viewDidLoadCalled = true
        // Имитация вызова загрузки новых фото, например, для первой строки
        // или вызвать loadNextPhotos(with: IndexPath(row: 0, section: 0))
        loadNextPhotos(for: .zero)
    }
    
    func largeImageURL(for index: Int) -> URL? {
        nil
    }
    
    func photo(for index: Int) -> Photo? {
        if index < photos.count {
            let photo = photos[index]
            photoReturned = true
            return photo
        }
        return nil
    }
    
    func numberOfRowsInSection() -> Int {
        photos.count
    }
    
    func loadNextPhotos(for index: Int) {
        loadNextPhotosCalled = true
        view?.reloadData()
    }
    
    func didTapLike(for row: Int) {
        
    }
}
