//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Kira on 15.04.2025.
//

//import ImageFeed
import UIKit

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    
    var loadRequestCalled: Bool = false
    var updateCalled = false
    var reloadDataCalled = false
    var likeStateChanged = false
    
    var oldCount: Int?
    var newCount: Int?
    
    init(presenter: ImagesListPresenterProtocol?) {
        self.presenter = presenter
    }

    func reloadData() {
        reloadDataCalled = true
    }
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateCalled = true
        self.oldCount = oldCount
        self.newCount = newCount
    }
    
    func setIsLiked(for cell: ImagesListCell, isLiked: Bool) {
        let likeButtonImageName = isLiked ? "like_button_on" : "like_button_off"
        let likeButtonImage = UIImage(named: likeButtonImageName)
        cell.likeButton.setImage(likeButtonImage, for: .normal)
        likeStateChanged = true
    }
    
    func showError(_ message: String) {
        
    }
    
    func showProgressHUD() {
        
    }
    
    func hideProgressHUD() {
        
    }
}
