//
//  CurrencyRatesService.swift
//  SimpleCartConversion
//
//  Created by William Pompei on 01/09/2017.
//  Copyright © 2017 William Pompei. All rights reserved.
//

import Foundation

// MARK: -
protocol CurrencyConversionService{
    init(restAPI: RestAPIProtocol)
    
    func rates(completion: @escaping (SCResult<[Rate], SCRestAPIError>) -> Void)
}

// MARK: -
class CurrencyConversionServiceImpl: CurrencyConversionService{
    
    let LIVE_SERVICE = "live"
    let restAPI:RestAPIProtocol
    
    required init(restAPI: RestAPIProtocol){
        self.restAPI = restAPI
    }
}

extension CurrencyConversionServiceImpl{
    // MARK: -
    func rates(completion: @escaping (SCResult<[Rate], SCRestAPIError>) -> Void){
        
        func mapToRates(using dict:[String:Any]?) -> [Rate]{
            let rates = dict?.flatMap { (item: (key: String, value: Any)) -> Rate? in
                guard let rate = item.value as? Double else {
                    return nil
                }
                return Rate(to:item.key, value:rate)
                } ?? []
            return rates
        }
        
        restAPI.performGet(service: LIVE_SERVICE, success: { (jsonData: Any) in
            guard let dict = jsonData as? [String: Any],
                let quotes = dict["quotes"] as? [String: Any] else {
                    completion(SCResult<[Rate], SCRestAPIError>.failure(error: SCRestAPIError.parsing))
                    return
            }
            
            let rates = mapToRates(using: quotes)
            completion( SCResult<[Rate], SCRestAPIError>.success(value: rates))
        }) { (error: SCRestAPIError) in
                    completion(SCResult<[Rate], SCRestAPIError>.failure(error: error))
        }
    }
}
