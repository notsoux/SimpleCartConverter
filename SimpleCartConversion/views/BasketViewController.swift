//
//  BasketViewController.swift
//  SimpleCartConversion
//
//  Created by William Pompei on 01/09/2017.
//  Copyright © 2017 William Pompei. All rights reserved.
//

import UIKit

class BasketViewController: UIViewController, BasketUpdateProtocol {

    var basketViewModel: BasketViewModel?
    var controller: ControllerNavigation?
    
    @IBOutlet weak var basketTableView: UITableView!
    
    // MARK: -
    func setup(using controller: ControllerNavigation, basketViewModel: BasketViewModel){
        self.controller = controller
        self.basketViewModel = basketViewModel
    }
    
    @IBAction func checkoutButtonAction(_ sender: Any) {
        self.controller?.checkoutButtonAction()
    }
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: -
    private func viewSetup() {
        basketTableView.dataSource = self
    }
    
    // MARK: -
    func basketUpdate() {
        basketTableView.reloadData()
    }
    
}

extension BasketViewController{
    static let eggItem = BasketItem(label: "egg", dollarCost: 2.10/12.0)
    static let peasItem = BasketItem(label: "peas bag", dollarCost: 0.95)
    static let milkItem = BasketItem(label: "milk bottle", dollarCost: 1.30)
    static let beansItem = BasketItem(label: "beans can", dollarCost: 0.73)
    
    @IBAction func addEgg(_ sender: Any) {
        basketViewModel?.add(basketItem: BasketViewController.eggItem)
    }
    
    @IBAction func addPeas(_ sender: Any) {
        basketViewModel?.add(basketItem: BasketViewController.peasItem)
    }
    
    @IBAction func addMilkBottle(_ sender: Any) {
        basketViewModel?.add(basketItem: BasketViewController.milkItem)
    }
    
    @IBAction func addBeansCan(_ sender: Any) {
        basketViewModel?.add(basketItem: BasketViewController.beansItem)
    }
}

// MARK: -
protocol BasketUpdateProtocol: class{
    func basketUpdate()
}

class BasketViewModel {
    
    struct BasketItemContent{
        let basketItem:BasketItem
        let quantity: Int
    }
    
    var basketItems = [BasketItemContent]()
    
    weak var basketUpdateDelegate: BasketUpdateProtocol?
    
    // MARK: -
    init(delegate: BasketUpdateProtocol? = nil){
        basketUpdateDelegate = delegate
    }
    
    // MARK: -
    func add(basketItem: BasketItem, quantity: Int = 1){
        let item = BasketItemContent(basketItem: basketItem, quantity: quantity)
        basketItems.append( item)
        basketUpdateDelegate?.basketUpdate()
    }
    
    // MARK: -
    func itemsCount() -> Int {
        return basketItems.count
    }
    
    func item(at indexPath: IndexPath) -> BasketItemContent? {
        guard basketItems.count > indexPath.row else {
            return nil
        }
        return basketItems[indexPath.row]
    }
    
    func removeItem(at indexPath: IndexPath){
        basketItems.remove(at: indexPath.row)
    }
}

class BasketItem{
    let label: String
    let dollarCost: Double
    
    init(label: String, dollarCost: Double){
        self.label = label
        self.dollarCost = dollarCost
    }
}

extension BasketViewController: UITableViewDataSource{
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return basketViewModel?.itemsCount() ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let BASKET_CELL_IDENTIFIER = "BASKET_CELL_IDENTIFIER"
        let cell = tableView.dequeueReusableCell(withIdentifier: BASKET_CELL_IDENTIFIER) as! BasketCell
        if let basketItem = basketViewModel?.item(at: indexPath) {
            cell.setup(using: basketItem)
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath){
        guard editingStyle == .delete else {
            return
        }
        basketViewModel?.removeItem(at: indexPath)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

class BasketCell: UITableViewCell{
    
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemCost: UILabel!
    
    func setup(using basketItemContent: BasketViewModel.BasketItemContent){
        itemName.text = basketItemContent.basketItem.label
        itemCost.text = "\(basketItemContent.basketItem.dollarCost)"
    }
    
    override func prepareForReuse() {
        itemName.text = nil
        itemCost.text = nil
    }
    
}

