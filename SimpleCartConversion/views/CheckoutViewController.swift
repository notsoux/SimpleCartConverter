//
//  CheckoutViewController.swift
//  SimpleCartConversion
//
//  Created by William Pompei on 02/09/2017.
//  Copyright © 2017 William Pompei. All rights reserved.
//

import UIKit

class CheckoutViewController: UIViewController{
    
    var checkoutViewModel:CheckoutViewModel?
    var controller: ControllerNavigation?
    
    var activityContainerView:UIView?
    
    @IBOutlet weak var checkoutConversionTable: UITableView!
    @IBOutlet weak var checkoutValueLabel: UILabel!
    @IBOutlet weak var updateRatesButton: UIButton!
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("CheckoutViewController deinit ")
    }
    
    func setup(using controller: ControllerNavigation, checkoutViewModel: CheckoutViewModel){
        self.controller = controller
        self.checkoutViewModel = checkoutViewModel
    }
    
    // MARK: -
    private func viewSetup() {
        checkoutConversionTable.isHidden = true
        checkoutConversionTable.dataSource = self
        checkoutConversionTable.delegate = self
        
        checkoutValueLabel.text = checkoutViewModel?.initialCheckoutValue()
        setupActivity()
        checkoutViewModel?.setup()
    }
    
    private func setupActivity(){
        
        let frame = UIScreen.main.bounds
        self.activityContainerView = UIView(frame: frame)
        self.activityContainerView?.backgroundColor = UIColor.white
        self.activityContainerView?.isHidden = true
        if let containerView = self.activityContainerView {
            self.view.addSubview(containerView)
        }
    }
    
    // MARK: -
    @IBAction func updateRates(_ sender: Any) {
        checkoutViewModel?.setup()
    }
}

// MARK: -
extension CheckoutViewController: CheckoutProtocol{
    func setupFinished() {
        self.checkoutConversionTable.isHidden = false
        self.checkoutConversionTable.reloadData()
    }
    
    func setupError(error: SCRestAPIError) {
        controller?.error(error: .connection)
    }
    
    func updateCheckout(using value: Double){
        checkoutValueLabel.text = "\(value)"
    }
    
    func showActivity(){
        self.activityContainerView?.alpha = 0.6
        self.activityContainerView?.isHidden = false
    }
    
    func hideActivity(){
        UIView.animate(withDuration: 0.7, animations: {
            self.activityContainerView?.alpha = 0.0
        }) { _ in
            self.activityContainerView?.isHidden = true
        }
        
    }
}

protocol CheckoutProtocol: class{
    func setupFinished()
    func setupError(error: SCRestAPIError)
    func updateCheckout(using value: Double)
    func showActivity()
    func hideActivity()
}

struct Rate{
    let to:String
    let value:Double
}

class CheckoutViewModel {
    
    var rates = [Rate]()
    let basketViewModel: BasketViewModel
    
    weak var delegate: CheckoutProtocol?
    let conversionService: CurrencyConversionService
    init(basketViewModel: BasketViewModel, conversionService: CurrencyConversionService, delegate: CheckoutProtocol? = nil){
        self.delegate = delegate
        self.basketViewModel = basketViewModel
        self.conversionService = conversionService
    }
    
    func setup(){
        delegate?.showActivity()
        conversionService.rates { [weak self] (result: SCResult<[Rate], SCRestAPIError>) in
            switch result{
            case let .success(value: rates):
                self?.rates = rates
                self?.delegate?.setupFinished()
            case let .failure(error: error):
                self?.delegate?.setupError(error: error)
            }
            self?.delegate?.hideActivity()
        }
    }
    
    // MARK: -
    func itemsCount() -> Int {
        return rates.count
    }
    
    func item(at indexPath: IndexPath) -> Rate?{
        guard indexPath.row < rates.count else {
            return nil
        }
        let item = rates[indexPath.row]
        return item
    }
    
    func select(at indexPath: IndexPath){
        guard let rate = item(at: indexPath) else {
            return
        }
        let convertedCost = basketViewModel.basketItems.reduce( 0) { (result: Double, item: BasketViewModel.BasketItemContent) -> Double in
            result + Double(item.quantity) * item.basketItem.dollarCost * rate.value
        }
        delegate?.updateCheckout(using: convertedCost)
    }
    
    // MARK: -
    func initialCheckoutValue() -> String{
        return "---"
    }
}

extension CheckoutViewController: UITableViewDataSource{
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return checkoutViewModel?.itemsCount() ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let CONVERSIONRATE_CELL_IDENTIFIER = "CONVERSIONRATE_CELL_IDENTIFIER"
        let cell = tableView.dequeueReusableCell(withIdentifier: CONVERSIONRATE_CELL_IDENTIFIER) as! ConversionRateCell
        if let item = checkoutViewModel?.item(at: indexPath) {
            cell.setup(using: item)
        }
        return cell
    }
}

extension CheckoutViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkoutViewModel?.select(at: indexPath)
    }
}

class ConversionRateCell: UITableViewCell{
    
    @IBOutlet weak var conversionTo: UILabel!
    @IBOutlet weak var conversionRate: UILabel!
    
    func setup(using rate: Rate){
        conversionTo.text = rate.to
        conversionRate.text = "\(rate.value)"
    }
    
    override func prepareForReuse() {
        conversionTo.text = nil
        conversionRate.text = nil
    }
    
}
