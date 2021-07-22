//
//  BasketViewController.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 1/16/21.
//  Copyright © 2021 Zouhair Sassi. All rights reserved.
//

import UIKit
import JGProgressHUD

class BasketViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var basketTotalLabel: UILabel!
    @IBOutlet weak var totalItemsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkOutButtonOutlet: UIButton!

    //MARK: - Vars
    var basket: Basket?
    var allItems: [Item] = []
    var purchasedItemIds : [String] = []
    let hud = JGProgressHUD(style: .dark)

    var environment: String = PayPalEnvironmentNoNetwork {
        willSet (newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    var payPalConfig = PayPalConfiguration()


    //MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = footerView
        self.setupPayPal()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (MUser.currentUser() != nil) {
            self.loadBasketFromFirestore()
        } else {
            self.updateTotalLabels(true)
        }
    }

    //MARK: - IBActions

    @IBAction func checkOutButtonPressed(_ sender: Any) {
        if (MUser.currentUser()!.onBoard) {
            /*self.tempFunction()
            self.addItemsToPurchaseHistory(self.purchasedItemIds)
            self.emptyTheBasket()*/
            self.payButtonPressed()
        } else {
            self.hud.textLabel.text = "Please complete your profile"
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.0)
        }
    }

    //MARK: - Download basket
    private func loadBasketFromFirestore() {
        downloadBasketFromFirestore(MUser.currentID()) { (basket) in
            self.basket = basket
            self.getBasketItems()
        }
    }

    private func getBasketItems() {
        if basket != nil {
            downloadItems(basket!.itemsIds) { (allItems) in
                self.allItems = allItems
                self.updateTotalLabels(false)
                self.tableView.reloadData()
            }
        }
    }

    //MARK: - Helper functions

    private func tempFunction() {
        for item in allItems {
            purchasedItemIds.append(item.id)
        }
    }

    private func updateTotalLabels(_ isEmpty: Bool) {
        if (isEmpty) {
            totalItemsLabel.text = "0"
            basketTotalLabel.text = returnBasketTotalPrice()
        } else {
            totalItemsLabel.text = "\(allItems.count)"
            basketTotalLabel.text = returnBasketTotalPrice()
        }
        checkoutButtonStatusUpdate()
    }

    private func returnBasketTotalPrice() -> String {
        var totalPrice = 0.0
        for item in allItems {
            totalPrice += item.price
        }
        return "Total price: " + convertToCurrency(totalPrice)
    }

    private func emptyTheBasket() {
        purchasedItemIds.removeAll()
        allItems.removeAll()
        self.tableView.reloadData()
        basket!.itemsIds = []
        updateBasketInFirestore(basket!, withValues: [KITEMIDS : basket!.itemsIds]) { (error) in
            if (error != nil) {
                print("Error updateing basket", error?.localizedDescription)
            }
            self.getBasketItems()
        }
    }

    private func addItemsToPurchaseHistory(_ itemsIds: [String]) {
        if (MUser.currentUser() != nil) {
            let newItemIds = MUser.currentUser()!.purchasedItemIds + itemsIds
            updateCurrentUserInFirestore(withValues: [KPURCHASEDITEMSIDS : newItemIds]) { (error) in
                if (error != nil) {
                    print("Error adding purchased items", error!.localizedDescription)
                }
            }

        }
    }

    //MARK: - Navigation

    private func showItemView(withItem: Item) {
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "itemView") as! ItemViewController
        itemVC.item = withItem
        self.navigationController?.pushViewController(itemVC, animated: true)
    }

    //MARK: - Control checkoutButton

    private func checkoutButtonStatusUpdate() {
        checkOutButtonOutlet.isEnabled = allItems.count > 0
        if (checkOutButtonOutlet.isEnabled) {
            checkOutButtonOutlet.backgroundColor = #colorLiteral(red: 1, green: 0.5843137255, blue: 0, alpha: 1)
        } else {
            disableCheckoutButton()
        }
    }

    private func disableCheckoutButton() {
        checkOutButtonOutlet.isEnabled = false
        checkOutButtonOutlet.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
    }

    private func removeItemFromBasket(itemId: String) {
        for i in 0..<basket!.itemsIds.count {
            if itemId == basket?.itemsIds[i] {
                basket?.itemsIds.remove(at: i)
                return
            }
        }
    }

    //MARK: - PayPal

    private func setupPayPal() {
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName = "ZMarket Dev Market"
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/us/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/us/webapps/mpp/ua/useragreement-full")

        payPalConfig.languageOrLocale = Locale.preferredLanguages.first
        payPalConfig.payPalShippingAddressOption = .both
    }

    private func payButtonPressed() {
        var itemsToBuy: [PayPalItem] = []
        for item in allItems {
            let tempItem = PayPalItem(name: item.name, withQuantity: 1, withPrice: NSDecimalNumber(value: item.price), withCurrency: "USD", withSku: nil)
            purchasedItemIds.append(item.id)
            itemsToBuy.append(tempItem)
        }

        let subTotal = PayPalItem.totalPrice(forItems: itemsToBuy)
        let shippingCost = NSDecimalNumber(string: "50.0")
        let tax = NSDecimalNumber(string: "5.00")

        let paymentDetails = PayPalPaymentDetails(subtotal: subTotal, withShipping: shippingCost, withTax: tax)

        let total = subTotal.adding(shippingCost).adding(tax)
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Payment to ZMarket", intent: .sale)
        payment.items = itemsToBuy
        payment.paymentDetails = paymentDetails

        if (payment.processable) {
            let paymentView = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            self.present(paymentView!, animated: true, completion: nil)
        } else {
            print("Payment not processable")
        }
    }
}

extension BasketViewController: PayPalPaymentDelegate {
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("Payment cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }

    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        paymentViewController.dismiss(animated: true) {
            self.addItemsToPurchaseHistory(self.purchasedItemIds)
            self.emptyTheBasket()
        }
    }
}

extension BasketViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        cell.generateCell(allItems[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }

    //MARK: - UITableview Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(withItem: allItems[indexPath.row])
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let itemToDelete = allItems[indexPath.row]
            allItems.remove(at: indexPath.row)
            tableView.reloadData()
            removeItemFromBasket(itemId: itemToDelete.id)
            updateBasketInFirestore(basket!, withValues: [KITEMIDS : basket!.itemsIds]) { (error) in
                if (error != nil) {
                    print("error updating the basket", error!.localizedDescription)
                }
                self.getBasketItems()
            }
        }
    }
}
