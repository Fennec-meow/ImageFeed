//
//  AuthViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Kira on 08.04.2025.
//

import Foundation

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}
