//
//  AppControllerTest.swift
//  SimpleCartConversion
//
//  Created by William Pompei on 02/09/2017.
//  Copyright © 2017 William Pompei. All rights reserved.
//

import XCTest
@testable import SimpleCartConversion

class AppControllerTest: XCTestCase {
    
    var appController: AppController!
    
    override func setUp() {
        super.setUp()
        appController  = AppController(urlSession: MockURLSession())
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_init() {
        XCTAssertNotNil(appController.errorViewController)
        XCTAssertNotNil(appController.storyboard)
        XCTAssertNotNil(appController.navigationController)
    }
    
    func test_startController(){
        _ = appController.startController()
        XCTAssertNotNil(appController.basketViewModel)
        XCTAssertEqual(appController.navigationController.viewControllers.count, 1)
        XCTAssertTrue(appController.navigationController.viewControllers[0] is BasketViewController)
    }

    func test_checkoutButtonAction_someItemInBasket(){
        let basketViewModel = BasketViewModel()
        basketViewModel.add(basketItem: BasketItem(label: "test", dollarCost: 1.9))
        appController.basketViewModel = basketViewModel
        appController.checkoutButtonAction()
        XCTAssertTrue(appController.navigationController.topViewController is CheckoutViewController)
    }

    func test_checkoutButtonAction_noItemInBasket(){
        _ = appController.startController()
        let basketViewModel = BasketViewModel()
        appController.basketViewModel = basketViewModel
        appController.checkoutButtonAction()
        XCTAssertTrue(appController.navigationController.viewControllers[0] is BasketViewController)
    }

    func test_checkoutButtonAction_noBasketViewModel(){
        appController.checkoutButtonAction()
        XCTAssertTrue(appController.navigationController.topViewController == appController.errorViewController)
    }
}
