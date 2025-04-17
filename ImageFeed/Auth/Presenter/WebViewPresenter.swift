//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Kira on 07.04.2025.
//

import Foundation
import WebKit

// MARK: - WebViewPresenterProtocol

protocol WebViewPresenterProtocol {
    var view: WebViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from navigationAction: WKNavigationAction) -> String?
}

// MARK: - WebViewPresenter

final class WebViewPresenter {
    
    // MARK: Public Property
    
    weak var view: WebViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    
    // MARK: Constructor
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
}

// MARK: - Public Methods

extension WebViewPresenter {
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}

// MARK: - Private Methods

private extension WebViewPresenter {
    func loadAuthView() {
        guard var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString) else { return }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else { return }
        
        let request = URLRequest(url: url)
        view?.load(request: request)
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}

// MARK: - WebViewPresenterProtocol

extension WebViewPresenter: WebViewPresenterProtocol {
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        
        loadAuthView()
        didUpdateProgressValue(CGFloat.zero)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return code(from: url)
        }
        return nil
    }
}

// MARK: - Constants

private extension WebViewPresenter {
    
    // MARK: UrlConstants
    
    enum UrlConstants {
        static let urlComponentsPath = "/oauth/authorize/native"
    }
    
    // MARK: StringConstants
    
    enum StringConstants {
        static let codeItem = "code"
    }
}
