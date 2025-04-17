//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Kira on 15.04.2025.
//

//import ImageFeed
import UIKit

final class ProfileViewControllerSpy: UIViewController, ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfilePresenterProtocol?
    
    var profileUpdateCalled: Bool = false
    var navigationToSplashScreenCalled: Bool = false
    var updatePictureCalled: Bool = false
    
    override func viewDidLoad() {
        presenter?.viewDidLoad()
    }
    
    func updatePicture(url: URL) {
        updatePictureCalled = true
    }
    
    func showProgressHUD() {
        
    }
    
    func hideProgressHUD() {
        
    }
    
    func updateProfileView(profile: Profile?) {
        profileUpdateCalled = true
    }
    
    func switchToSplashScreen() {
        navigationToSplashScreenCalled = true
    }
}
