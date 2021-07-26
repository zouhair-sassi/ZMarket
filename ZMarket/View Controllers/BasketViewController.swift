//
//  BasketViewController.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 1/16/21.
//  Copyright © 2021 Zouhair Sassi. All rights reserved.
//

import UIKit
import JGProgressHUD
import Stripe

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
    var totalPrice = 0


    //MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = footerView

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
            self.showPaymentOptions()
        } else {
            self.showNotification(text: "Please complete your profile", isError: true)
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

    private func finishPayment(_ token: STPToken) {
        self.totalPrice = 0
        for item in allItems {
            purchasedItemIds.append(item.id)
            self.totalPrice += Int(item.price)
        }

        self.totalPrice = self.totalPrice * 100
        StripeClient.shared.createAndConfirmPayment(token, amount: self.totalPrice) { (error) in
            if (error == nil) {
                self.emptyTheBasket()
                self.addItemsToPurchaseHistory(self.purchasedItemIds)
                //Show notificcation
                self.showNotification(text: "Payment Succ", isError: false)
            } else {
                self.showNotification(text: error!.localizedDescription, isError: true)
            }
        }
    }

    private func showNotification(text: String, isError: Bool) {
        if (isError) {
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
        } else {
            self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        }
        self.hud.textLabel.text = text
        self.hud.show(in: self.view)
        self.hud.dismiss(afterDelay: 2.0)
    }

    private func showPaymentOptions() {
        let alert = UIAlertController(title: "Payment Options",
                                      message: "Chose prefered payment",
                                      preferredStyle: .actionSheet)

        let cardAction = UIAlertAction(title: "Pay with Card",
                                       style: .default) { (action) in
            //Show card number
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "cardinfoVC") as! CardInfoViewController
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cardAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
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

extension BasketViewController: CardInfoViewcontrollerDelegate {
    func didClicDone(_ token: STPToken) {
        self.finishPayment(token)
    }

    func didClickCancel() {
        self.showNotification(text: "Payment Canceled", isError: true)
    }

}
