//
//  SwiftKeychainWrapper.swift
//  ImageFeed
//
//  Created by Kira on 21.01.2025.
//

import Foundation
import SwiftKeychainWrapper

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
}



//final class OAuth2TokenStorage {
//    private enum Keys: String {
//        case token
//    }
//    var token: String? {
//        get {
//            userDefaults.string(forKey: Keys.token.rawValue)
//        }
//        set {
//            userDefaults.set(newValue, forKey: Keys.token.rawValue)
//        }
//    }
//    private let userDefaults = UserDefaults.standard
//}
