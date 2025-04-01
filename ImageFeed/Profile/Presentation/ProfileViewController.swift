//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Kira on 13.01.2025.
//

import UIKit
import Foundation
import Kingfisher
import WebKit

// MARK: - ProfileViewController

final class ProfileViewController: UIViewController {
    
    // MARK: Private Property
    
    private let profileImageService = ProfileImageService.shared
    private let profileService = ProfileService.shared
    private let splashViewController = SplashViewController()
    private let swiftKeychainWrapper = SwiftKeychainWrapper()
    private var username: String? = String()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private lazy var ui: UI = {
        let ui = createUI()
        layout(ui)
        return ui
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        updateAvatar(notification: .init(name: .init(StringConstants.updateAvatar)))
        updateProfileDetails()
        getAvatar()
    }
    
    // Перегружаем конструктор
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        addObserver()
    }
    
    // Определяем конструктор, необходимый при декодировании
    // класса из Storyboard
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addObserver()
    }
    
    // MARK: Deinit (Destructor)
    
    deinit {
        removeObserver()
    }
}

// MARK: - Private Methods

private extension ProfileViewController {
    func getAvatar() {
        UIBlockingProgressHUD.show()
        profileImageService.fetchProfileImageURL(username ?? String()) { [weak self] result in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let stringUrl):
                guard
                    let url = URL(string: stringUrl)
                else { return }
                DispatchQueue.main.async {
                    let processor = RoundCornerImageProcessor(
                        cornerRadius: 61,
                        backgroundColor: .clear
                    )
                    UIBlockingProgressHUD.dismiss()
                    self.ui.avatarImageView.kf.indicatorType = .activity
                    self.ui.avatarImageView.kf.setImage(
                        with: url,
                        placeholder: ImageConstants.personCircle,
                        options: [
                            .processor(processor),
                            .scaleFactor(UIScreen.main.scale),
                            .transition(.fade(1)),
                            .cacheOriginalImage
                        ])
                }
            case let .failure(error):
                print("getAvatar: \(error) when loading avatar \n.")
            }
        }
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAvatar(notification:)),
            name: ProfileImageService.didChangeNotification,
            object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: ProfileImageService.didChangeNotification,
            object: nil)
    }
    
    func updateProfileDetails() {
        guard let profile = profileService.profile else {
            return
        }
        self.username = profile.userName
        ui.nameLabel.text = profile.name
        ui.loginNameLabel.text = profile.loginName
        ui.descriptionLabel.text = profile.bio
    }
    
    @objc func didTapLogoutButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "Да",
            style: .default,
            handler: { [weak self] _ in
                guard let self else { return }
                logout()
            }))
        
        alert.addAction(UIAlertAction(
            title: "Нет",
            style: .default,
            handler: { _ in
            }))
        present(alert, animated: true)
    }
    
    @objc func updateAvatar(notification: Notification) {
        DispatchQueue.main.async {
            guard
                let profileImageURL = ProfileImageService.shared.avatarURL,
                let url = URL(string: profileImageURL)
            else { return }
            let processor = RoundCornerImageProcessor(
                cornerRadius: 61,
                backgroundColor: .clear
            )
            self.ui.avatarImageView.kf.indicatorType = .activity
            self.ui.avatarImageView.kf.setImage(
                with: url,
                placeholder: nil,
                options: [
                    .processor(processor)
                ]
            )
        }
    }
    
    func switchToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Fatal Error") }
        window.rootViewController = splashViewController
    }
}

// MARK: - clearStorage

private extension ProfileViewController {
    
    func logout() {
        clearStorage()
        clearToken()
        switchToSplashScreen()
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

// MARK: - UI Configuring

private extension ProfileViewController {
    
    // MARK: UI components
    
    struct UI {
        
        let avatarImageView: UIImageView
        let nameLabel: UILabel
        let loginNameLabel: UILabel
        let descriptionLabel: UILabel
        let logoutButton: UIButton
    }
    
    // MARK: Creating UI components
    
    func createUI() -> UI {
        
        let avatarImageView = UIImageView()
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.image = ImageConstants.avatarImage
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.layer.masksToBounds = true
        
        view.addSubview(avatarImageView)
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = FontsConstants.ysDisplayBold
        nameLabel.textColor = .ypWhite
        view.addSubview(nameLabel)
        
        let loginNameLabel = UILabel()
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.font = FontsConstants.ysDisplayMedium
        loginNameLabel.textColor = .ypGray
        view.addSubview(loginNameLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = FontsConstants.ysDisplayMedium
        descriptionLabel.textColor = .ypWhite
        view.addSubview(descriptionLabel)
        
        let logoutButton = UIButton.systemButton(
            with: ImageConstants.logoutButton,
            target: self,
            action: #selector(didTapLogoutButton)
        )
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.tintColor = .ypRed
        view.addSubview(logoutButton)
        
        return .init(
            avatarImageView: avatarImageView,
            nameLabel: nameLabel,
            loginNameLabel: loginNameLabel,
            descriptionLabel: descriptionLabel,
            logoutButton: logoutButton
        )
    }
    
    // MARK: UI component constants
    
    func layout(_ ui: UI) {
        
        NSLayoutConstraint.activate( [
            
            ui.avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            ui.avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            ui.avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            ui.avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            ui.nameLabel.leadingAnchor.constraint(equalTo: ui.avatarImageView.leadingAnchor),
            ui.nameLabel.topAnchor.constraint(equalTo: ui.avatarImageView.bottomAnchor, constant: 8),
            
            ui.loginNameLabel.topAnchor.constraint(equalTo: ui.nameLabel.bottomAnchor, constant: 8),
            ui.loginNameLabel.leadingAnchor.constraint(equalTo: ui.nameLabel.leadingAnchor),
            
            ui.descriptionLabel.topAnchor.constraint(equalTo: ui.loginNameLabel.bottomAnchor, constant: 8),
            ui.descriptionLabel.leadingAnchor.constraint(equalTo: ui.loginNameLabel.leadingAnchor),
            
            ui.logoutButton.centerYAnchor.constraint(equalTo: ui.avatarImageView.centerYAnchor),
            ui.logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
            
        ])
    }
}

// MARK: - Constants

private extension ProfileViewController {
    
    // MARK: FontsConstants
    
    enum FontsConstants {
        static let ysDisplayBold: UIFont = .init(name: "YSDisplay-Bold", size: 23) ?? UIFont.systemFont(ofSize: 23)
        static let ysDisplayMedium: UIFont = .init(name: "YSDisplay-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13)
    }
    
    // MARK: ImageConstants
    
    enum ImageConstants {
        static let avatarImage = UIImage(named: "avatar")
        static let logoutButton = UIImage(named: "logout_button") ?? UIImage()
        static let personCircle = UIImage(named: "person.circle")
    }
    
    // MARK: StringConstants
    
    enum StringConstants {
        static let updateAvatar = "ProfileImageService.didChangeNotification"
    }
}
