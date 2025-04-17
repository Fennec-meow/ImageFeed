//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Kira on 08.04.2025.
//

import Foundation
import WebKit

// MARK: - ProfilePresenterProtocol

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func getAvatar()
    func logout()
}

// MARK: - ProfilePresenter

final class ProfilePresenter {
    
    // MARK: Public Property
    
    weak var view: ProfileViewControllerProtocol?
    
    // MARK: Private Property
    
    private let swiftKeychainWrapper = SwiftKeychainWrapper()
    private let profileImageService = ProfileImageService.shared
    private let profileService = ProfileService.shared
    private var username: String? = String()
}

private extension ProfilePresenter {
    func updateProfileDetails() {
        guard let profile = profileService.profile else {
            return
        }
        self.username = profile.userName
        view?.updateProfileView(profile: profile)
    }
    
    func _logout() {
        clearStorage()
        clearToken()
        view?.switchToSplashScreen()
    }
    
    func clearStorage() {
        // Очищаем все куки из хранилища.
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища.
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища.
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    func clearToken() {
        swiftKeychainWrapper.deleteToken()
    }
}

// MARK: - ProfilePresenterProtocol

extension ProfilePresenter: ProfilePresenterProtocol {
    
    func viewDidLoad() {
        updateProfileDetails()
        getAvatar()
    }
    
    func getAvatar() {
        view?.showProgressHUD()
        profileImageService.fetchProfileImageURL(username ?? String()) { [weak self] result in
            guard let self else { return }
            view?.hideProgressHUD()
            switch result {
            case .success(let stringUrl):
                guard
                    let url = URL(string: stringUrl)
                else { return }
                view?.updatePicture(url: url)
            case let .failure(error):
                print("getAvatar: \(error) when loading avatar \n.")
            }
        }
    }
    
    func logout() {
        _logout()
    }
}


