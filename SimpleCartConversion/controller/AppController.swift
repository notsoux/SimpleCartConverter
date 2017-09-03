//
//  AppController.swift
//  SimpleCartConversion
//
//  Created by William Pompei on 02/09/2017.
//  Copyright © 2017 William Pompei. All rights reserved.
//

import Foundation
import UIKit

// MARK: -
class ErrorViewController: UIViewController{
}

// MARK: -
class AppController {
    
    let storyboard: UIStoryboard
    let errorViewController: UIViewController
    var basketViewModel:BasketViewModel?
    let navigationController = UINavigationController()
    let restAPI: RestAPI
    
    init(urlSession: URLSessionProtocol){
        restAPI = RestAPI(urlSession: urlSession)
        storyboard = UIStoryboard(name: "Main", bundle: nil)
        errorViewController = storyboard.instantiateViewController(withIdentifier: "ERROR_VC_IDENTIFIER") as! ErrorViewController
    }
    
    // MARK: -
    func startController() -> UIViewController {
        let basketVC = storyboard.instantiateViewController(withIdentifier: "BASEKT_VC_IDENTIFIER") as! BasketViewController
        let basketViewModel = BasketViewModel(delegate: basketVC)
        self.basketViewModel = basketViewModel
        basketVC.setup(using: self, basketViewModel: basketViewModel)
        
        navigationController.pushViewController(basketVC, animated: false)
        return navigationController
    }
}

// MARK: -
protocol ControllerNavigation{
    func checkoutButtonAction()
    func error(error: SCRestAPIError)
}

enum SCNavigationError {
    case noItemInBasket
}

extension AppController: ControllerNavigation{
    func checkoutButtonAction(){
        let vcToPush: UIViewController
        let checkoutVC = storyboard.instantiateViewController(withIdentifier: "CHECKOUT_VC_IDENTIFIER") as! CheckoutViewController
        if let basketViewModel = basketViewModel {
            if basketViewModel.itemsCount() <= 0 {
                navigationError(error: .noItemInBasket)
               return
            }
            let conversionService = CurrencyConversionServiceImpl(restAPI: restAPI)
            let checkoutViewModel = CheckoutViewModel(basketViewModel: basketViewModel, conversionService: conversionService, delegate: checkoutVC)
            checkoutVC.setup(using: self, checkoutViewModel: checkoutViewModel)
            vcToPush = checkoutVC
        } else {
            vcToPush = errorViewController
        }
        navigationController.pushViewController(vcToPush, animated: true)
    }
    
    func error(error: SCRestAPIError){
        let message: String
        switch error{
        case .connection: message = "Service error -> check connection and retry"
        case .parsing: message = "Application error...ask someone...maybe the developer :("
        }
        showAlertError(using: message)
    }
    
    func navigationError(error: SCNavigationError){
        let message: String
        switch error{
        case .noItemInBasket: message = "No item in basket...please add at least one"
        }
        showAlertError(using: message)

    }
    
    private func showAlertError(using message: String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        navigationController.present(alert, animated: true, completion: nil)
    }

}



