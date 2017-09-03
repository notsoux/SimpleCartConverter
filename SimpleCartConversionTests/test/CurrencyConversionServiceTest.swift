//
//  CurrencyConversionServiceTest.swift
//  SimpleCartConversion
//
//  Created by William Pompei on 03/09/2017.
//  Copyright © 2017 William Pompei. All rights reserved.
//

import XCTest
@testable import SimpleCartConversion

class CurrencyConversionServiceTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_connectionOK_parsingOK() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "service_testData_OK", ofType: "json")!
        let jsonToReturnForSuccess: String! = try? String(contentsOfFile: path)

        let restAPI = MockRestAPIFactory.success(returnValue: jsonToReturnForSuccess)
        
        let service = CurrencyConversionServiceImpl(restAPI: restAPI)
        
        let expect = expectation(description: "restAPI wait")
        service.rates { (result: SCResult<[Rate], SCRestAPIError>) in
            switch result {
            case let .success(rates):
                XCTAssertEqual(rates.count, 168)
            case .failure(_):
                XCTFail()
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func test_connectionKO() {
        
        let restAPI = MockRestAPIFactory.failure(using: .connection)
        
        let service = CurrencyConversionServiceImpl(restAPI: restAPI)
        
        let expect = expectation(description: "restAPI wait")
        service.rates { (result: SCResult<[Rate], SCRestAPIError>) in
            switch result {
            case .success(_):
                XCTFail()
            case let .failure( error):
                XCTAssertEqual(error, .connection)
                break
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func test_connectionOK_parsingKO() {
        
        let restAPI = MockRestAPIFactory.failure(using: .parsing)
        
        let service = CurrencyConversionServiceImpl(restAPI: restAPI)
        
        let expect = expectation(description: "restAPI wait")
        service.rates { (result: SCResult<[Rate], SCRestAPIError>) in
            switch result {
            case .success(_):
                XCTFail()
            case let .failure( error):
                XCTAssertEqual(error, .parsing)
                break
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
}

