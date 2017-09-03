//
//  RestAPITest.swift
//  SimpleCartConversion
//
//  Created by William Pompei on 03/09/2017.
//  Copyright © 2017 William Pompei. All rights reserved.
//

import XCTest
@testable import SimpleCartConversion

class RestAPITest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_responseOK_jsonParsingOK() {
        
        let mockURLSession = MockURLConnectionFactory.connectionSuccess(returnValue: "{}")
        let restAPI = RestAPI(urlSession: mockURLSession)
        
        let expect = expectation(description: "restAPI wait")
        restAPI.performGet(service: "test_service", success: { _ in
            expect.fulfill()
        }) { _ in
            XCTFail()
            expect.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_responseOK_jsonParsingKO() {
        
        let mockURLSession = MockURLConnectionFactory.connectionSuccess(returnValue: "{asdasda")
        let restAPI = RestAPI(urlSession: mockURLSession)
        
        let expect = expectation(description: "restAPI wait")
        restAPI.performGet(service: "test_service", success: { _ in
            XCTFail()
            expect.fulfill()
        }) { (error: SCRestAPIError) in
            XCTAssertEqual(error, .parsing)
            expect.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_responseKO() {
        
        let mockURLSession = MockURLConnectionFactory.connectionFailure()
        let restAPI = RestAPI(urlSession: mockURLSession)
        
        let expect = expectation(description: "restAPI wait")
        restAPI.performGet(service: "test_service", success: { _ in
            XCTFail()
            expect.fulfill()
        }) { (error: SCRestAPIError) in
            XCTAssertEqual(error, .connection)
            expect.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
}
