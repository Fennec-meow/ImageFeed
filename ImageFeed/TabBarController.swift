//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Kira on 11.03.2025.
//

import UIKit

// MARK: - TabBarController

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViewControllers()
    }
}

private extension TabBarController {
    
    private func setupViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        // Настройка ImagesListViewController
        let imagesListPresenter = ImagesListPresenter()
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: StringConstants.imagesListViewController) as! ImagesListViewController
        imagesListViewController.presenter = imagesListPresenter
        imagesListPresenter.view = imagesListViewController
        imagesListViewController.tabBarItem = UITabBarItem(
            title: String(),
            image: ImageConstants.tabEditorialActive,
            selectedImage: nil
        )
        
        // Настройка ProfileViewController
        let profilePresenter = ProfilePresenter()
        let profileViewController = ProfileViewController(presenter: profilePresenter)
        profilePresenter.view = profileViewController
        profileViewController.tabBarItem = UITabBarItem(
            title: String(),
            image: ImageConstants.tabProfileActive,
            selectedImage: nil
        )
        
        // Установка контроллеров в tabBarController
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}

// MARK: - Constants

private extension TabBarController {
    
    // MARK: ImageConstants
    
    enum StringConstants {
        static let imagesListViewController = "ImagesListViewController"
    }
    
    // MARK: ImageConstants
    
    enum ImageConstants {
        static let tabEditorialActive = UIImage(named: "tab_editorial_active")
        static let tabProfileActive = UIImage(named: "tab_profile_active")
    }
}
