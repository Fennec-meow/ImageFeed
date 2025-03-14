//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Kira on 20.01.2025.
//

import UIKit
//import ProgressHUD

// MARK: - protocol AuthViewControllerDelegate

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

// MARK: - class AuthViewController

final class AuthViewController: UIViewController {
    
    // MARK: Идентификатор сигвея
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    // MARK: delegate: AuthViewControllerDelegate
    
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: Кнопка старта
    
    @IBOutlet weak var startButton: UIButton!
    
    // MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        
        startButton.titleLabel?.font = UIFont(name: "YSDisplay-Bold", size: 17)
    }
    
    // MARK: Метод prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(showWebViewSegueIdentifier)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: Конфигурация кнопки
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }
}

// MARK: - AuthViewController: WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
        UIBlockingProgressHUD.show()
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
        UIBlockingProgressHUD.dismiss()
    }
}
