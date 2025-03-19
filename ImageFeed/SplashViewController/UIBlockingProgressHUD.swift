//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Kira on 28.02.2025.
//

import UIKit
import ProgressHUD

//MARK: - UIBlockingProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    // статичный метод
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    // симметричный метод
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
    
}
