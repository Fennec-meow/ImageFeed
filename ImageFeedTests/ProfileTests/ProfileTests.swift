//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Kira on 15.04.2025.
//

@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewControllerSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled) //behaviour verification
    }
    
    func testGetAvatar() {
        //given
        let profileService = ProfileImageService.shared
        let presenter = ProfilePresenterSpy(service: profileService)
        let viewController = ProfileViewControllerSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.getAvatar()
        
        //then
        XCTAssertTrue(presenter.getAvatarCalled) //behaviour verification
    }
    
    func testLogout() {
        //given
        let profileService = ProfileImageService.shared
        let presenter = ProfilePresenterSpy(service: profileService)
        let viewController = ProfileViewControllerSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.logout()
        
        //then
        XCTAssertTrue(presenter.logoutCalled) //behaviour verification
    }
    
    func testUpdatePicture() {
        //given
        let profileService = ProfileImageService.shared
        let presenter = ProfilePresenterSpy(service: profileService)
        let viewController = ProfileViewControllerSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        let url: URL = URL(string: String()) ?? URL(fileURLWithPath: String())
        viewController.updatePicture(url: url)
        
        //then
        XCTAssertTrue(viewController.updatePictureCalled) //behaviour verification
    }
    
    func testUpdateProfileView() {
        //given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewControllerSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        viewController.updateProfileView(profile: nil)
        
        //then
        XCTAssertTrue(viewController.profileUpdateCalled) //behaviour verification
    }
    
    func testSwitchToSplashScreen() {
        //given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewControllerSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        viewController.switchToSplashScreen()
        
        //then
        XCTAssertTrue(viewController.navigationToSplashScreenCalled) //behaviour verification
    }
}
