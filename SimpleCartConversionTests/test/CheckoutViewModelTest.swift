//
//  CheckoutViewModelTest.swift
//  SimpleCartConversion
//
//  Created by William Pompei on 03/09/2017.
//  Copyright © 2017 William Pompei. All rights reserved.
//

import XCTest
@testable import SimpleCartConversion

class CheckoutViewModelTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_setupOK() {
        let basketViewModel = BasketViewModel()
        let conversionService = MockCurrencyConversionService(restAPI: MockRestAPIFactory.success(returnValue: ""))
        conversionService.failure = false
        conversionService.successResult = [Rate(to: "EUR", value: 1.2), Rate(to: "ASD", value: 1.5)]
        
        let delegate = MockCheckoutProtocol()
        let checkoutViewModel = CheckoutViewModel(basketViewModel: basketViewModel, conversionService: conversionService, delegate: delegate)
        checkoutViewModel.setup()
        
        XCTAssertEqual(delegate.setupErrorCalled, 0)
        XCTAssertEqual(checkoutViewModel.rates, conversionService.successResult)
    }
    
    func test_conversion(){
        let basketViewModel = BasketViewModel()
        basketViewModel.add(basketItem: BasketItem(label: "itemOne", dollarCost: 1.0))
        basketViewModel.add(basketItem: BasketItem(label: "itemTwo", dollarCost: 1.5))
        let conversionService = MockCurrencyConversionService(restAPI: MockRestAPIFactory.success(returnValue: ""))
        conversionService.failure = false
        conversionService.successResult = [Rate(to: "EUR", value: 1.2), Rate(to: "ASD", value: 1.5)]
        
        let delegate = MockCheckoutProtocol()
        let checkoutViewModel = CheckoutViewModel(basketViewModel: basketViewModel, conversionService: conversionService, delegate: delegate)
        checkoutViewModel.setup()
        
        let indexPath = IndexPath(row: 0, section: 0)
        checkoutViewModel.select(at: indexPath)
        XCTAssertEqual(delegate.updateCheckoutCalled, 1)
        
        //(1.0 + 1.5) * 1.2
        XCTAssertEqual(delegate.lastUpdateCheckoutValue, 3.0)
        
    }
}

extension Rate: Equatable{
    public static func ==(lhs: Rate, rhs: Rate) -> Bool{
        return lhs.to == rhs.to && lhs.value == rhs.value
    }
}

class MockCheckoutProtocol: CheckoutProtocol {
    var setupFinishedCalled = 0
    
    var setupErrorCalled = 0
    var lastSetupError: SCRestAPIError!
    
    var updateCheckoutCalled = 0
    var lastUpdateCheckoutValue: Double!
    
    func setupFinished(){
        setupFinishedCalled += 1
    }
    
    func setupError(error: SCRestAPIError){
        setupErrorCalled += 1
        lastSetupError = error
    }
    
    func updateCheckout(using value: Double){
        updateCheckoutCalled += 1
        lastUpdateCheckoutValue = value
    }
    
    func showActivity(){
    }
    
    func hideActivity(){
    }
}

class MockCurrencyConversionService: CurrencyConversionService {
    
    var failure: Bool!
    var failureError: SCRestAPIError!
    
    var successResult = [Rate]()
    
    required init(restAPI: RestAPIProtocol){
    }
    
    func rates(completion: @escaping (SCResult<[Rate], SCRestAPIError>) -> Void){
        if failure {
            completion(SCResult<[Rate], SCRestAPIError>.failure(error: failureError))
        } else {
            completion(SCResult<[Rate], SCRestAPIError>.success(value: successResult))
        }
    }
}
