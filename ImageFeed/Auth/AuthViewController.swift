//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Kira on 20.01.2025.
//

import UIKit
import ProgressHUD

// MARK: - AuthViewControllerDelegate

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

// MARK: - AuthViewController

final class AuthViewController: UIViewController {
    
    
    // MARK: UI Components
    
    private lazy var ui: UI = {
        let ui = createUI()
        layout(ui)
        return ui
    }()
    
    
    // MARK: UI Components
    
//    @IBOutlet weak var startButton: UIButton!
    
    // MARK: Public Property
    
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: Private Property
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: prepare UIStoryboardSegue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewController = segue.destination as? WebViewController
            else { fatalError("Failed to prepare for \(showWebViewSegueIdentifier)") }
            webViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - UI Configuration

private extension AuthViewController {
    func setupUI() {
        ui.startButton.titleLabel?.font = LayoutConstants.ysDisplayBold
        
        configureNavigationBar()
    }
    
    // MARK: Configuring the navigation bar
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.backIndicatorImage = ImageConstants.navBackButton
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = ImageConstants.navBackButton
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: String(),
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.backBarButtonItem?.tintColor = ColorConstants.ypBlack
    }
}

// MARK: - Constants

private extension AuthViewController {
    enum LayoutConstants {
        static let ysDisplayBold: UIFont = .init(name: "YSDisplay-Bold", size: 17) ?? UIFont.systemFont(ofSize: 17)
    }
    
    enum PointConstants {
        
    }
    
    enum StringConstants {
        
    }
    
    enum ImageConstants {
        static let navBackButton: UIImage = .init(named: "nav_back_button") ?? UIImage()
    }
    
    enum ColorConstants {
        static let ypBlack: UIColor = .init(named: "ypBlack") ?? UIColor.black
    }
}

// MARK: - AuthViewController: WebViewControllerDelegate

extension AuthViewController: WebViewControllerDelegate {
    func webViewController(_ vc: WebViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
        UIBlockingProgressHUD.show()
    }
    
    func webViewControllerDidCancel(_ vc: WebViewController) {
        dismiss(animated: true)
        UIBlockingProgressHUD.dismiss()
    }
}

// MARK: - UI Configuring

private extension AuthViewController {
    
    // MARK: UI components
    
    struct UI {
        
        let unsplashImageView: UIImageView
        let startButton: UIButton
    }
    
    // MARK: Creating UI components
    
    func createUI() -> UI {
        
        let unsplashImageView = UIImageView()
        unsplashImageView.image = UIImage(named: "Logo_of_Unsplash")
        
        unsplashImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(unsplashImageView)
        
        let startButton = UIButton(type: .system)
        
        startButton.setTitleColor(.ypBlack, for: .normal)
        startButton.backgroundColor = .ypWhite
        startButton.setTitle("Войти", for: .normal)
        startButton.titleLabel?.font = UIFont(name: "YSDisplay-Bold", size: 17)
        startButton.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
        startButton.layer.cornerRadius = 16
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startButton)

        return .init(
            unsplashImageView: unsplashImageView,
            startButton: startButton
        )
    }
    
    // MARK: UI component constants
    
    func layout(_ ui: UI) {
        
        NSLayoutConstraint.activate( [
            
            ui.unsplashImageView.widthAnchor.constraint(equalToConstant: 60),
            ui.unsplashImageView.heightAnchor.constraint(equalToConstant: 60),
            ui.unsplashImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            ui.unsplashImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            ui.startButton.heightAnchor.constraint(equalToConstant: 48),
            ui.startButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            ui.startButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            ui.startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
    }
    @objc func didTapStartButton() {
        // Проверяем, есть ли у контроллера UINavigationController
        guard let navigationController = navigationController else {
            print("NavigationController не найден")
            return
        }
        
        // Инициализируем WebViewController
        let webViewController = WebViewController()
        webViewController.delegate = self // Если есть делегат, устанавливаем его
        // Переходим на WebViewController
        navigationController.pushViewController(webViewController, animated: true)
    }

}
