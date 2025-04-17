//
//  WebViewPresenterSpy.swift
//  ImageFeed
//
//  Created by Kira on 07.04.2025.
//

import Foundation
//import ImageFeed
import WebKit

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
    
    }
    
    func code(from navigationAction: WKNavigationAction) -> String? {
        return nil
    }
}
