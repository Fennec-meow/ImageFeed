//
//  WebViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Kira on 08.04.2025.
//

import Foundation

protocol WebViewControllerDelegate: AnyObject {
    func webViewController(_ vc: WebViewController, didAuthenticateWithCode code: String)
    func webViewControllerDidCancel(_ vc: WebViewController)
}
