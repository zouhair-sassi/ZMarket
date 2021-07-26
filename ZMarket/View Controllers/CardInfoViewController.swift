//
//  CardInfoViewController.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 7/23/21.
//  Copyright © 2021 Zouhair Sassi. All rights reserved.
//

import UIKit
import Stripe

protocol CardInfoViewcontrollerDelegate {
    func didClicDone(_ token: STPToken)
    func didClickCancel()
}

class CardInfoViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var doneButtonOutlet: UIButton!

    let paymentCardTextField = STPPaymentCardTextField()
    var delegate: CardInfoViewcontrollerDelegate?

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(paymentCardTextField)

        paymentCardTextField.delegate = self
        self.paymentCardTextField.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: paymentCardTextField,
                                                   attribute: .top,
                                                   relatedBy: .equal,
                                                   toItem: doneButtonOutlet,
                                                   attribute: .bottom,
                                                   multiplier: 1, constant: 30))

        self.view.addConstraint(NSLayoutConstraint(item: paymentCardTextField,
                                                   attribute: .trailing,
                                                   relatedBy: .equal,
                                                   toItem: self.view,
                                                   attribute: .trailing,
                                                   multiplier: 1, constant: -20))

        self.view.addConstraint(NSLayoutConstraint(item: paymentCardTextField,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: self.view,
                                                   attribute: .leading,
                                                   multiplier: 1, constant: 20))

    }
    
    //MARK: - IBActions

    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismissView()
    }

    @IBAction func doneButtonPresed(_ sender: Any) {
        self.processCard()
    }

    //MARK: - Helpers
    private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }

    private func processCard() {
        let cardParams = STPCardParams()
        cardParams.number = paymentCardTextField.cardNumber
        cardParams.expMonth = UInt(paymentCardTextField.expirationMonth)
        cardParams.expYear = UInt(paymentCardTextField.expirationYear)
        cardParams.cvc = paymentCardTextField.cvc
        STPAPIClient.shared.createToken(withCard: cardParams) { (token, error) in
            if (error == nil) {
                self.delegate?.didClicDone(token!)
                self.dismissView()
            } else {
                print("Error processing card token", error!.localizedDescription)

            }
        }
    }
}


extension CardInfoViewController: STPPaymentCardTextFieldDelegate {

    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        doneButtonOutlet.isEnabled = textField.isValid
    }
}
