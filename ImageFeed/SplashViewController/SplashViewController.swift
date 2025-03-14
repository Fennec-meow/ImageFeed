//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Kira on 21.01.2025.
//

import UIKit

// MARK: - class SplashViewController

final class SplashViewController: UIViewController {

    private let showAuthenticationScreenSegueIdentifier = "ShowAuthentication"
    // MARK: OAuth2Service
    
    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ImageFeed.ProfileImageService.shared
    
    // MARK: OAuth2TokenStorage
    
    private let swiftKeychainWrapper = SwiftKeychainWrapper()
        
    // MARK: UI
    
    private var vectorImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Vector"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        
        setupContent()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if swiftKeychainWrapper.getToken() != nil {
            UIBlockingProgressHUD.show()
            let token = swiftKeychainWrapper.getToken() ?? "nil"
            print("viewDidAppear: найден токен: \(token).\n") // Принт найденного токена
            fetchProfile(token: token)
            UIBlockingProgressHUD.dismiss()
            switchToTabBarController()
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let storyboard = UIStoryboard(name: "Main", bundle: .main)
                guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
                authViewController.delegate = self
                authViewController.modalPresentationStyle = .fullScreen
                print("viewDidAppear: токен не найден, переход к AuthViewController.\n") // Принт перехода к экрану аутентификации
                self.present(authViewController, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: Private methods
    
    private func switchToTabBarController() {
        
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.switchToTabBarController()
            }
            return
        }
        
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController else {
            fatalError("Unable to instantiate TabBarViewController")
        }
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        print("switchToTabBarController: переход к TabBarController.\n") // Принт перехода к TabBarController
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            print("authViewController: аутентификация завершена с кодом: \(code).\n") // Принт завершения аутентификации
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let token):
                print("fetchOAuthToken: успешно получен токен: \(token).\n") // Принт успешного получения токена
                // Сохраняем токен в хранилище
                self.fetchProfile(token: token)
                // Переход к TabBarController
                self.switchToTabBarController()
            case .failure:
                print("fetchOAuthToken: ошибка при получении токена.\n") // Принт ошибки получения токена
                break
            }
        }
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let profile):
                    print("fetchProfile: успешно получен профиль для пользователя \(profile.userName).\n") // Принт успешного получения профиля
                    ProfileImageService.shared.fetchProfileImageURL(profile.userName) { result in
                        switch result {
                        case .success(let avatarURL):
                            DispatchQueue.main.async {
                                self.profileImageService.setAvatarUrlString(avatarUrl: avatarURL)
                                print("fetchProfile: успешно установлен URL аватара: \(avatarURL).\n") // Принт успешного установки URL аватара
                            }
                        case .failure:
                            print("fetchProfile: ошибка при получении URL аватара.\n") // Принт ошибки получения URL аватара
                            return
                        }
                        
                    }
                    UIBlockingProgressHUD.dismiss()
                    self.switchToTabBarController()
                case .failure:
                    print("fetchProfile: ошибка при получении профиля.\n") // Принт ошибки получения профиля
                    break
                }
            }
        }
    }
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = swiftKeychainWrapper.getToken() else {
            print("didAuthenticate: токен не найден.\n") // Принт, если токен не найден
            return
        }
        print("didAuthenticate: найден токен: \(token).\n") // Принт найденного токена
        fetchProfile(token: token)
    }
}

//    private func fetchProfile(_ token: String) {
//        UIBlockingProgressHUD.show()
//        profileService.fetchProfile(token) { [weak self] result in
//            UIBlockingProgressHUD.dismiss()
//
//            guard let self = self else { return }
//
//            switch result {
//            case .success:
//                self.switchToTabBarController()
//
//            case .failure:
//                print("Failed to fetch profile")
//
//                break
//            }
//        }
//    }

// MARK: - Prepare for segue

extension SplashViewController {
    
    func setupContent() {
        [
            vectorImageView
        ].forEach { subview in
            view.addSubview(subview)
        }
    }
    
    func vectorImageViewViewConstraints() -> [NSLayoutConstraint] {
        [
            vectorImageView.widthAnchor.constraint(equalToConstant: 72),
            vectorImageView.heightAnchor.constraint(equalToConstant: 75),
            vectorImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            vectorImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ]
    }
    
    func setupConstraints() {
        let vectorImageViewViewConstraints = vectorImageViewViewConstraints()
        
        // MARK: Активация констрейнтов
        
        NSLayoutConstraint.activate(
            vectorImageViewViewConstraints
        )
    }
}

