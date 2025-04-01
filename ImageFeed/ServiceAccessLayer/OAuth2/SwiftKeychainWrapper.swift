//
//  SwiftKeychainWrapper.swift
//  ImageFeed
//
//  Created by Kira on 21.01.2025.
//

import Foundation
import SwiftKeychainWrapper

// MARK: - SwiftKeychainWrapper

final class SwiftKeychainWrapper {
    
    func setToken(token: String?) {
        guard let token = token else { return }
        let isSuccess = KeychainWrapper.standard.set(token, forKey: "Auth token")
        guard isSuccess else {
            return
        }
    }
    func getToken() -> String? {
        return KeychainWrapper.standard.string(forKey: "Auth token")
    }
    
    func deleteToken() {
        KeychainWrapper.standard.removeObject(forKey: "Auth token")
    }
}
