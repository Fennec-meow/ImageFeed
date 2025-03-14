//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Kira on 13.01.2025.
//

import UIKit
import Foundation
import Kingfisher

// MARK: - class ProfileViewController

final class ProfileViewController: UIViewController {
    
    // MARK: ProfileService
    
    let profileService = ProfileService.shared
    let splashViewController = SplashViewController()
    private let swiftKeychainWrapper = SwiftKeychainWrapper()
    
    // MARK: NSObjectProtocol
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: UI Components

        private lazy var ui: UI = {
            let ui = createUI()
            layout(ui)
            return ui
        }()

    
//    // MARK: Аватарка
//    
//    private var avatarImageView: UIImageView = {
//        let imageView = UIImageView()
//        
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.image = UIImage(named: "avatar")
//        imageView.layer.cornerRadius = 35
//        
//        return imageView
//    }()
//    
//    // MARK: Имя пользователя
//    
//    private var nameLabel: UILabel = {
//        let label = UILabel()
//        
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "Екатерина Новикова"
//        label.font = UIFont(name: "YSDisplay-Bold", size: 23)
//        label.textColor = .ypWhite
//        return label
//    }()
//    
//    // MARK: Личная ссылка на пользователя
//    
//    private var loginNameLabel: UILabel = {
//        let label = UILabel()
//        
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "@ekaterina_nov"
//        label.font = UIFont(name: "YSDisplay-Medium", size: 13)
//        label.textColor = .ypGray
//        return label
//    }()
//    
//    // MARK: Статус пользователя
//    
//    private var descriptionLabel: UILabel = {
//        let label = UILabel()
//        
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "Hello, world!"
//        label.font = UIFont(name: "YSDisplay-Medium", size: 13)
//        label.textColor = .ypWhite
//        return label
//    }()
//    
//    // MARK: Кнопка выхода из личного кабинета
//    
//    private lazy var logoutButton: UIButton = {
//        let button = UIButton.systemButton(
//            with: UIImage(named: "logout_button") ?? UIImage(),
//            target: self,
//            action: #selector(didTapLogoutButton)
//        )
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.tintColor = .ypRed
//        return button
//    }()
//    
    // MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        profileImageServiceObserver = NotificationCenter.default
//            .addObserver(
//                forName: ProfileImageService.didChangeNotification,
//                object: nil,
//                queue: .main
//            ) { [weak self] _ in
//                guard let self = self else { return }
//                self.updateAvatar(notification: .init(name: .init("ProfileImageService.didChangeNotification")))                              // 6
//            }
        updateAvatar(notification: .init(name: .init("ProfileImageService.didChangeNotification")))
        
        let token = swiftKeychainWrapper.getToken() ?? "nil"
        
        
       // updateProfileDetails(token: token)
        updateProfileDetails()
//        setupContentProfile()
//        setupConstraintsProfile()
        view.backgroundColor = .ypBlack
    }
  
    
//    @objc
    
    // MARK: updateProfileDetails
    /*
    private func updateProfileDetails(token: String) {
        // Запрос профиля с использованием токена
        profileService.fetchProfile(token) { result in
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    // Обновление UI на главном потоке
                    self.nameLabel.text = profile.name
                    self.loginNameLabel.text = profile.loginName
                    self.descriptionLabel.text = profile.bio
                }
                print(profile)
            case .failure(let error):
                print("Ошибка при выборке профиля: \(error.localizedDescription)")
            }
        }
    }
     */
    private func updateProfileDetails() {
        guard let profile = profileService.profile else {
            return
        }
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
    
//    @objc private func updateAvatar(notification: Notification) {
//        DispatchQueue.main.async {
//            guard
//                let profileImageURL = ProfileImageService.shared.avatarURL,
//                let url = URL(string: profileImageURL)
//            else { return }
//            let processor = RoundCornerImageProcessor(
//                cornerRadius: 35,
//                backgroundColor: .clear
//            )
//            self.avatarImageView.kf.indicatorType = .activity
//            self.avatarImageView.kf.setImage(with: url)
//        }
//    }
    
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
            self.ui.avatarImageView.kf.setImage(with: url)
        }
    }
    
    // MARK: Действия кнопки выхода из личного кабинета
    
    @objc private func didTapLogoutButton() {
        print("logout_button \n")
    }
}

// MARK: - Констрейнты

private extension ProfileViewController {
    
    // MARK: UI компоненты
    
    struct UI {
                
        
//        let avatarImageView = UIImageView
//        let nameLabel = UILabel
//        let loginNameLabel = UILabel
//        let descriptionLabel = UILabel
//        let logoutButton = UIButton
        let avatarImageView: UIImageView
        let nameLabel: UILabel
        let loginNameLabel: UILabel
        let descriptionLabel: UILabel
        let logoutButton: UIButton
    }
    
    // MARK: тут будут создаваться UI компоненты
    
    func createUI() -> UI {
        
        let avatarImageView = UIImageView()
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.image = UIImage(named: "avatar")
        avatarImageView.layer.cornerRadius = 35
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        nameLabel.textColor = .ypWhite
        
        let loginNameLabel = UILabel()
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.font = UIFont(name: "YSDisplay-Medium", size: 13)
        loginNameLabel.textColor = .ypGray
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = UIFont(name: "YSDisplay-Medium", size: 13)
        descriptionLabel.textColor = .ypWhite
        
        let logoutButton = UIButton.systemButton(
            with: UIImage(named: "logout_button") ?? UIImage(),
            target: self,
            action: #selector(didTapLogoutButton)
        )
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.tintColor = .ypRed
        
        
        return .init(
            avatarImageView: avatarImageView,
            nameLabel: nameLabel,
            loginNameLabel: loginNameLabel,
            descriptionLabel: descriptionLabel,
            logoutButton: logoutButton
        )
    }
    
    // MARK: тут будут лежать констрейнты к UI компонентам
    func layout(_ ui: UI) {
        
//        avatarImageView.widthAnchor.constraint(equalToConstant: 70),
        avatarImageView.heightAnchor.constraint(equalToConstant: 70),
        avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
        avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        
        nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
        nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8)

        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
        loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
        descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor)
        
        logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        
        // MARK: Активация констрейнтов
        
        NSLayoutConstraint.activate(
            avatarImageView +
            nameLabel +
            loginNameLabel +
            descriptionLabel +
            logoutButton
        )
    }
    
    
    
    
    //    func setupContentProfile() {
    //        [
    //            avatarImageView,
    //            nameLabel,
    //            loginNameLabel,
    //            descriptionLabel,
    //            logoutButton
    //        ].forEach { subview in
    //            view.addSubview(subview)
    //        }
    //    }
    //
    //    func setupConstraintsProfile() {
    //        let avatarImageViewConstraints = avatarImageViewConstraints()
    //        let nameLabelConstraints = nameLabelConstraints()
    //        let loginNameLabelConstraints = loginNameLabelConstraints()
    //        let descriptionLabelConstraints = descriptionLabelConstraints()
    //        let logoutButtonConstraints = logoutButtonConstraints()
    //
    //        // MARK: Активация констрейнтов
    //
    //        NSLayoutConstraint.activate(
    //            avatarImageViewConstraints +
    //            nameLabelConstraints +
    //            loginNameLabelConstraints +
    //            descriptionLabelConstraints +
    //            logoutButtonConstraints
    //        )
    //    }
    //
    // MARK: Констрейнты аватврки
    
//    func avatarImageViewConstraints() -> [NSLayoutConstraint] {
//        [
//            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
//            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
//            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
//            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
//        ]
//    }
//    
//    // MARK: Констрейнты имени пользователя
//    
//    func nameLabelConstraints() -> [NSLayoutConstraint] {
//        [
//            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
//            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8)
//        ]
//    }
//    
//    // MARK: Констрейнты личной ссылки на пользователя
//    
//    func loginNameLabelConstraints() -> [NSLayoutConstraint] {
//        [
//            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
//            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
//        ]
//    }
//    
//    // MARK: Констрейнты статуса пользователя
//    
//    func descriptionLabelConstraints() -> [NSLayoutConstraint] {
//        [
//            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
//            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor)
//        ]
//    }
//    
//    // MARK: Констрейнты кнопки выхода из личного кабинета
//    
//    func logoutButtonConstraints() -> [NSLayoutConstraint] {
//        [
//            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
//            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
//        ]
//    }
}
