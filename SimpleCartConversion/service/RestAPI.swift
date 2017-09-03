//
//  RestAPI.swift
//  SimpleCartConversion
//
//  Created by William Pompei on 03/09/2017.
//  Copyright © 2017 William Pompei. All rights reserved.
//

import Foundation

// MARK: -
public enum SCResult<T, E> {
    case success(value: T)
    case failure(error: E)
}

public enum SCRestAPIError: String {
    case parsing
    case connection
}

extension SCRestAPIError: Equatable{
    public static func ==(lhs: SCRestAPIError, rhs: SCRestAPIError) -> Bool{
        return true
    }
}

// MARK: -
protocol URLSessionProtocol {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask
}

protocol URLSessionDataTaskProtocol{
    func resume()
}

extension URLSession:URLSessionProtocol{
}

protocol RestAPIProtocol{
    func performGet(service: String,
                    success: @escaping (Any) -> Void,
                    failure: @escaping(SCRestAPIError) -> Void)
}

// MARK: -
struct RestAPI: RestAPIProtocol{
    
    static let BASE_URL = "http://apilayer.net/api"
    static let ACCESS_KEY_PARAM = URLQueryItem(name: "access_key", value: "ae9540dd57df78599465040bd72e0c6f")
    
    let urlSession: URLSessionProtocol
    init( urlSession: URLSessionProtocol){
        self.urlSession = urlSession
    }
    
    // MARK: -
    
    func performGet(service: String,
                    success: @escaping (Any) -> Void,
                    failure: @escaping(SCRestAPIError) -> Void){
        
        guard let url = URL(string: RestAPI.BASE_URL)?.appendingPathComponent(service),
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return
        }
        urlComponents.queryItems = [RestAPI.ACCESS_KEY_PARAM]
        
        guard let serverUrl = urlComponents.url else {
            return
        }
        
        let task = urlSession.dataTask(with: serverUrl) { (data: Data?, response: URLResponse?, error: Error?) in
            DispatchQueue.main.async {
                guard error == nil else {
                    failure(SCRestAPIError.connection)
                    return
                }
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                        failure(SCRestAPIError.parsing)
                        return
                }
                
                success( json)
            }
        }
        
        task.resume()
    }
    
}
