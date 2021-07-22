//
//  EditProfilViewController.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 7/16/21.
//  Copyright © 2021 Zouhair Sassi. All rights reserved.
//

import UIKit
import JGProgressHUD

class EditProfilViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!

    //MARK: - Vars
    let hud = JGProgressHUD(style: .dark)

    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadUserInfo()

    }
    

    //MARK: - IBActions
    @IBAction func saveBarButtonPressed(_ sender: Any) {
        self.dismissKeyboard()
        if (self.textFieldsHaveText()) {
            let withValues = [KFIRSTNAME : nameTextField.text!, KLASTNAME : surnameTextField.text!, KFULLNAME : (nameTextField.text!) + " " + (surnameTextField.text!), KFULLADDRESS : addressTextField.text!]
            updateCurrentUserInFirestore(withValues: withValues) { (error) in
                if (error == nil) {
                    self.hud.textLabel.text = ""
                    self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                } else {
                    self.hud.textLabel.text = error?.localizedDescription
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                }
            }
        } else {
            self.hud.textLabel.text = "All fields are required"
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.0)
        }
    }

    @IBAction func logOutButtonPressed(_ sender: Any) {
        self.logOutUser()
    }

    //MARK: - UpdateUI
    private func loadUserInfo() {
        if MUser.currentUser() != nil {
            let currentUser = MUser.currentUser()!
            self.nameTextField.text = currentUser.firstName
            self.surnameTextField.text = currentUser.lastName
            self.addressTextField.text = currentUser.fullAdress
        }
    }

    //MARK: - Helper funcs
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }

    private func textFieldsHaveText() -> Bool {
        return (nameTextField.text != "" && surnameTextField.text != "" && addressTextField.text != "")
    }

    private func logOutUser() {
        MUser.logOutCurrentUser { (error) in
            if (error == nil) {
                print("logged out")
                self.navigationController?.popViewController(animated: true)
            } else {
                print("Error logout \(error?.localizedDescription)")
            }
        }
    }
}
