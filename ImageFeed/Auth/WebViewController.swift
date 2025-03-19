//
//  WebViewController.swift
//  ImageFeed
//
//  Created by Kira on 20.01.2025.
//

import UIKit
import WebKit

// MARK: - WebViewControllerDelegate

protocol WebViewControllerDelegate: AnyObject {
    func webViewController(_ vc: WebViewController, didAuthenticateWithCode code: String)
    func webViewControllerDidCancel(_ vc: WebViewController)
}

// MARK: - WebViewController

final class WebViewController: UIViewController {
    
    // MARK: UI Components
    
    private lazy var ui: UI = {
        let ui = createUI()
        layout(ui)
        return ui
    }()
    
//    @IBOutlet private var webView: WKWebView!
//    @IBOutlet private var progressView: UIProgressView!
    
    // MARK: Public Property
    
    weak var delegate: WebViewControllerDelegate?
    
    // MARK: Private Property
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        estimatedProgressObservation = ui.webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.updateProgress()
             })
        
        ui.webView.navigationDelegate = self
        
        loadAuthView()
        updateProgress()
    }
    
    // MARK: didTapBackButton
    
    @IBAction private func didTapBackButton(_ sender: Any?) {
        delegate?.webViewControllerDidCancel(self)
    }
    
    // MARK: KVO
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ui.webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
        updateProgress()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ui.webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    // MARK: The update handler
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func updateProgress() {
        ui.progressView.progress = Float(ui.webView.estimatedProgress)
        ui.progressView.isHidden = fabs(ui.webView.estimatedProgress - 1.0) <= 0.0001
    }
}

// MARK: - URL formation

private extension WebViewController {
    func loadAuthView() {
        guard var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString) else {
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else { return }
        
        let request = URLRequest(url: url)
        ui.webView.load(request)
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            print("Code: \(String(describing: codeItem.value))\n")
            return codeItem.value
        } else {
            return nil
        }
    }
}

// MARK: - UI Configuring

private extension WebViewController {
    
    // MARK: UI components
    
    struct UI {

        let webView: WKWebView
        let progressView: UIProgressView
    }
    
    // MARK: Creating UI components
    
    func createUI() -> UI {
        
        let webView = WKWebView()
          
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        let progressView = UIProgressView()
         
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)

        return .init(
            webView: webView,
            progressView: progressView
        )
    }
    
    // MARK: UI component constants
    
    func layout(_ ui: UI) {
        
        NSLayoutConstraint.activate( [
            
            ui.webView.topAnchor.constraint(equalTo: view.superview!.topAnchor),
            ui.webView.leadingAnchor.constraint(equalTo: view.superview!.leadingAnchor),
            ui.webView.trailingAnchor.constraint(equalTo: view.superview!.trailingAnchor),
            ui.webView.bottomAnchor.constraint(equalTo: view.superview!.bottomAnchor),
        
            ui.progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            ui.progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            ui.progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            
        ])
    }
//    @objc func didTapStartButton() {
//        // Проверяем, есть ли у контроллера UINavigationController
//        guard let navigationController = navigationController else {
//            print("NavigationController не найден")
//            return
//        }
//        
//        // Инициализируем WebViewController
//        let webViewController = WebViewController()
//        webViewController.delegate = self // Если есть делегат, устанавливаем его
//        // Переходим на WebViewController
//        navigationController.pushViewController(webViewController, animated: true)
//    }

}
