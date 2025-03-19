//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Kira on 13.01.2025.
//

import UIKit
import Foundation
import Kingfisher

// MARK: - ProfileViewController

final class ProfileViewController: UIViewController {
    
    // MARK: ProfileService
    
    let profileService = ProfileService.shared
    let profileImageService = ProfileImageService.shared
    
    // MARK: Public Property
    
    let splashViewController = SplashViewController()
    
    var username: String? = String()
    
    // MARK: Private Property
    
    private let swiftKeychainWrapper = SwiftKeychainWrapper()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: UI Components
    
    private lazy var ui: UI = {
        let ui = createUI()
        layout(ui)
        return ui
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAvatar(notification: .init(name: .init("ProfileImageService.didChangeNotification")))
        
        updateProfileDetails()
        view.backgroundColor = .ypBlack
        getAvatar()
    }
    
    // MARK: updateProfileDetails
    
    private func updateProfileDetails() {
        guard let profile = profileService.profile else {
            return
        }
        self.username = profile.userName
        ui.nameLabel.text = profile.name
        ui.loginNameLabel.text = profile.loginName
        ui.descriptionLabel.text = profile.bio
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
    
    //     Определяем деструктор
    deinit {
        removeObserver()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAvatar(notification:)),
            name: ProfileImageService.didChangeNotification,
            object: nil)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: ProfileImageService.didChangeNotification,
            object: nil)
    }
    
    @objc private func updateAvatar(notification: Notification) {
        DispatchQueue.main.async {
            guard
                let profileImageURL = ProfileImageService.shared.avatarURL,
                let url = URL(string: profileImageURL)
            else { return }
            let processor = RoundCornerImageProcessor(
                cornerRadius: 35,
                backgroundColor: .clear
            )
            self.ui.avatarImageView.kf.indicatorType = .activity
            self.ui.avatarImageView.kf.setImage(
                with: url,
                placeholder: nil,
                options: [
                    .processor(processor)
                ])
        }
    }
}

// MARK: - Private Methods

private extension ProfileViewController {
    func getAvatar() {
        profileImageService.fetchProfileImageURL(username ?? String()) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let stringUrl):
                guard
                    let url = URL(string: stringUrl)
                else { return }
                DispatchQueue.main.async {
                    let processor = RoundCornerImageProcessor(
                        cornerRadius: 35,
                        backgroundColor: .clear
                    )
                    
                    self.ui.avatarImageView.kf.indicatorType = .activity
                    self.ui.avatarImageView.kf.setImage(
                        with: url,
                        placeholder: UIImage(named: "person.circle"),
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
        avatarImageView.image = UIImage(named: "avatar")
        avatarImageView.layer.cornerRadius = 35
        view.addSubview(avatarImageView)
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        nameLabel.textColor = .ypWhite
        view.addSubview(nameLabel)
        
        let loginNameLabel = UILabel()
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.font = UIFont(name: "YSDisplay-Medium", size: 13)
        loginNameLabel.textColor = .ypGray
        view.addSubview(loginNameLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = UIFont(name: "YSDisplay-Medium", size: 13)
        descriptionLabel.textColor = .ypWhite
        view.addSubview(descriptionLabel)
        
        let logoutButton = UIButton.systemButton(
            with: UIImage(named: "logout_button") ?? UIImage(),
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
    
    // MARK: The exit button from your personal account
    
    @objc func didTapLogoutButton() {
        print("logout_button \n")
    }
}
