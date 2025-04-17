//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Kira on 15.04.2025.
//

@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController?.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController?.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled) //behaviour verification
    }
    
    func testPresenterCallsLoadRequest() {
        // given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewControllerSpy(presenter: presenter)
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(presenter.loadNextPhotosCalled, "При viewDidLoad должен быть вызван loadNextPhotos")
    }
    
    ///
    func testLoadNextPhotosCalledWhenViewDidLoad() {
        // given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewControllerSpy(presenter: presenter)
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(presenter.loadNextPhotosCalled)
    }
    
    func testUpdateTableViewAnimated() {
        // given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewControllerSpy(presenter: presenter)
        presenter.view = viewController
        
        // when
        viewController.updateTableViewAnimated(oldCount: 5, newCount: 10)
        
        // then
        XCTAssertTrue(viewController.updateCalled)
        XCTAssertEqual(viewController.oldCount, 5)
        XCTAssertEqual(viewController.newCount, 10)
    }
    
    func testTableViewReloadsData() {
        // given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewControllerSpy(presenter: presenter)
        presenter.view = viewController
        
        presenter.loadNextPhotos(for: .zero)
        
        XCTAssertTrue(viewController.reloadDataCalled)
    }
    
    func testGetPhotoFromArray() {
        // given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewControllerSpy(presenter: presenter)
        presenter.view = viewController
        
        _ = presenter.photo(for: .zero)
        
        XCTAssertEqual(presenter.photoReturned, true)
    }
}
