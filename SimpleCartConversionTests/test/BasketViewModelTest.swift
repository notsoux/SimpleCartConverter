//
//  BasketViewModelTest.swift
//  SimpleCartConversion
//
//  Created by William Pompei on 03/09/2017.
//  Copyright © 2017 William Pompei. All rights reserved.
//

import XCTest
@testable import SimpleCartConversion

class BasketViewModelTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_basketUpdate_add() {
        let basketViewModelDelegate = MockBasketViewModelDelegate()
        let basketViewModel = BasketViewModel(delegate: basketViewModelDelegate)
        XCTAssertEqual(basketViewModel.basketItems.count, 0)
        
        let basketItem = BasketItem(label: "test", dollarCost: 1.2)
        basketViewModel.add(basketItem: basketItem)
        XCTAssertEqual(basketViewModelDelegate.called, 1)
        XCTAssertEqual(basketViewModel.itemsCount(), 1)
        
        let indexPath = IndexPath(row: 0, section: 0)
        XCTAssertEqual(basketViewModel.item(at: indexPath)!.basketItem, basketItem)
    }
    
    func test_remove(){
        let basketViewModelDelegate = MockBasketViewModelDelegate()
        let basketViewModel = BasketViewModel(delegate: basketViewModelDelegate)
        let basketItemOne = BasketItem(label: "testOne", dollarCost: 1.2)
        basketViewModel.add(basketItem: basketItemOne)

        let basketItemTwo = BasketItem(label: "testTwo", dollarCost: 3.4)
        basketViewModel.add(basketItem: basketItemTwo)
        let indexPath = IndexPath(row: 1, section: 0)
        basketViewModel.removeItem(at: indexPath)

        XCTAssertEqual(basketViewModel.itemsCount(), 1)
        XCTAssertEqual(basketViewModel.item(at: IndexPath(row: 0, section: 0))!.basketItem, basketItemOne)
    }
    
    func test_basketUpdate_itemIndexOutOfBound() {
        let basketViewModelDelegate = MockBasketViewModelDelegate()
        let basketViewModel = BasketViewModel(delegate: basketViewModelDelegate)
        XCTAssertEqual(basketViewModel.basketItems.count, 0)
        
        let basketItem = BasketItem(label: "test", dollarCost: 1.2)
        basketViewModel.add(basketItem: basketItem)
        
        let indexPath = IndexPath(row: 123, section: 0)
        XCTAssertNil(basketViewModel.item(at: indexPath))
    }
    
}


extension BasketViewModel.BasketItemContent: Equatable {
    public static func ==(lhs: BasketViewModel.BasketItemContent, rhs: BasketViewModel.BasketItemContent) -> Bool {
        return lhs.basketItem == rhs.basketItem &&
        lhs.quantity == rhs.quantity
    }
}

extension BasketItem: Equatable{
    public static func ==(lhs: BasketItem, rhs: BasketItem) -> Bool {
        return lhs.label == rhs.label && lhs.dollarCost == rhs.dollarCost
    }
}

class MockBasketViewModelDelegate: BasketUpdateProtocol{
    
    var called = 0
    func basketUpdate() {
        called += 1
    }
    
}
