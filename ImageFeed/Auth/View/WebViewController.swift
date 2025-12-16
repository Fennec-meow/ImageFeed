//
//  WebViewController.swift
//  ImageFeed
//
//  Created by Kira on 20.01.2025.
//

import UIKit
import WebKit

// MARK: - WebViewControllerProtocol

protocol WebViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

// MARK: - WebViewController

final class WebViewController: UIViewController {
    
    // MARK: UI Components
    
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    // MARK: Public Property
    
    weak var delegate: WebViewControllerDelegate?
    var presenter: WebViewPresenterProtocol?
    
    // MARK: Private Property
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
        presenter?.didUpdateProgressValue(webView.estimatedProgress)
        webView.accessibilityIdentifier = "UnsplashWebView"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupObservers()
        presenter?.didUpdateProgressValue(webView.estimatedProgress)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    // MARK: Overrides
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            presenter?.didUpdateProgressValue(webView.estimatedProgress)
        } else {
            super.observeValue(
                forKeyPath: keyPath,
                of: object,
                change: change,
                context: context
            )}
    }
}

// MARK: - WebViewControllerProtocol

extension WebViewController: WebViewControllerProtocol {
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}

// MARK: - Private Methods

private extension WebViewController {
    
    @IBAction func didTapBackButton(_ sender: Any?) {
        delegate?.webViewControllerDidCancel(self)
    }
    
    func setupObservers() {
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil
        )
    }
    
    func removeObservers() {
        webView.removeObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            context: nil
        )
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = presenter?.code(from: navigationAction) {
            delegate?.webViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

// MARK: - UI Configuration

private extension WebViewController {
    
    func setupUI() {
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self else { return }
                 presenter?.didUpdateProgressValue(webView.estimatedProgress)
             })
        
        webView.navigationDelegate = self
    }
}

// MARK: - Constants

private extension WebViewController {
    
    // MARK: UrlConstants
    
    enum UrlConstants {
        static let urlComponentsPath = "/oauth/authorize/native"
    }
    
    // MARK: StringConstants
    
    enum StringConstants {
        static let codeItem = "code"
    }
}
