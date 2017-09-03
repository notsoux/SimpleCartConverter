//
//  MockURLSession.swift
//  SimpleCartConversion
//
//  Created by William Pompei on 02/09/2017.
//  Copyright © 2017 William Pompei. All rights reserved.
//

import Foundation
@testable import SimpleCartConversion


class MockURLSessionDataTask: URLSessionDataTask{
    override func resume(){
        
    }
}

class MockURLSession: URLSessionProtocol{
    
    let data: Data?
    let response: URLResponse?
    let error: Error?
    
    init(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil){
        self.data = data
        self.response = response
        self.error = error
    }
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask {
        completionHandler(data, response, error)
        return MockURLSessionDataTask()
    }
}

// MARK: -
struct MockRestAPIFactory {
    static func success(returnValue jsonString: String) -> RestAPIProtocol {
        let mockURLSession = MockURLConnectionFactory.connectionSuccess(returnValue: jsonString)
        let restAPI = RestAPI(urlSession: mockURLSession)
        return restAPI
    }
    
    static func failure(using error: SCRestAPIError) -> RestAPIProtocol {
        let restAPI: RestAPIProtocol
        switch error{
        case .connection:
            let mockURLSession = MockURLConnectionFactory.connectionFailure()
            restAPI = RestAPI(urlSession: mockURLSession)
        case .parsing:
            let mockURLSession = MockURLConnectionFactory.connectionSuccess(returnValue: "{asdasda")
            restAPI = RestAPI(urlSession: mockURLSession)
        }
        
        return restAPI
    }
}

// MARK: -
struct MockURLConnectionFactory{
    static func connectionSuccess(returnValue jsonString: String) -> URLSessionProtocol{
        let url = URL(string: "http://www.example.com")
        let response = URLResponse(url: url!, mimeType: nil, expectedContentLength: 0, textEncodingName: "utf-8")
        
        let mockURLSession = MockURLSession( data: jsonString.data(using:  .utf8), response: response)
        
        return mockURLSession
    }
    
    static func connectionFailure() -> URLSessionProtocol{
        let mockURLSession = MockURLSession( error: NSError())
        
        return mockURLSession
    }
}
