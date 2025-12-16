//
//  ProfilePresenterSpy.swift
//  ImageFeedTests
//
//  Created by Kira on 15.04.2025.
//

//import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var service: ProfileImageService?
    
    var viewDidLoadCalled: Bool = false
    var getAvatarCalled: Bool = false
    var logoutCalled: Bool = false
    
    convenience init(service: ProfileImageService?) {
        self.init()
        self.service = service
    }
    
    
    func viewDidLoad() {
         viewDidLoadCalled = true
    }
    
    func getAvatar() {
        getAvatarCalled = true
    }
    
    func logout() {
        logoutCalled = true
    }
}


