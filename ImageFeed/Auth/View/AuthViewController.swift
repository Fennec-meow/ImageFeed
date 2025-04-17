//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Kira on 20.01.2025.
//

import UIKit

// MARK: - AuthViewController

final class AuthViewController: UIViewController {
    
    // MARK: UI Components
    
    @IBOutlet weak var startButton: UIButton!
    
    // MARK: Public Property
    
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: Private Property
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewController = segue.destination as? WebViewController
            else {
                assertionFailure("Не удалось подготовиться к \(showWebViewSegueIdentifier)")
                return
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewController
            webViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - Private Methods

private extension AuthViewController {
    
    @objc func didTapStartButton() {
        // Инициализируем WebViewController
        let webViewController = WebViewController()
        webViewController.delegate = self // Если есть делегат, устанавливаем его
        // Переходим на WebViewController
        present(webViewController, animated: true)
    }
}

// MARK: - UI Configuration

private extension AuthViewController {
    
    func setupUI() {
        startButton.titleLabel?.font = FontsConstants.ysDisplayBold
        
        configureNavigationBar()
    }
    
    // MARK: Configuring the navigation bar
    
    func configureNavigationBar() {
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

// MARK: - Constants

private extension AuthViewController {
    
    // MARK: FontsConstants
    
    enum FontsConstants {
        static let ysDisplayBold: UIFont = .init(name: "YSDisplay-Bold", size: 17) ?? UIFont.systemFont(ofSize: 17)
    }
    
    // MARK: ImageConstants
    
    enum ImageConstants {
        static let navBackButton: UIImage = .init(named: "nav_back_button") ?? UIImage()
    }
    
    // MARK: ColorConstants
    
    enum ColorConstants {
        static let ypBlack: UIColor = .init(named: "ypBlack") ?? UIColor.black
    }
}
