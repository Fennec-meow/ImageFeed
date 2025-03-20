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
        startButton.titleLabel?.font = LayoutConstants.ysDisplayBold
        
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
    
    @objc func didTapStartButton() {
        // Инициализируем WebViewController
        let webViewController = WebViewController()
        webViewController.delegate = self // Если есть делегат, устанавливаем его
        // Переходим на WebViewController
        present(webViewController, animated: true)
    }
}

// MARK: - Constants

private extension AuthViewController {
    enum LayoutConstants {
        static let ysDisplayBold: UIFont = .init(name: "YSDisplay-Bold", size: 17) ?? UIFont.systemFont(ofSize: 17)
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
