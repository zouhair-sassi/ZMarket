//
//  FinishRegistrationViewController.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 7/16/21.
//  Copyright © 2021 Zouhair Sassi. All rights reserved.
//

import UIKit
import JGProgressHUD

class FinishRegistrationViewController: UIViewController {
    //MARK: - IBOutlets
    
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var doneButtonOutlet: UIButton!

    //MARK: - Vars
    let hud = JGProgressHUD(style: .dark)



    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        surnameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        addressTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)

    }

    //MARK: - IBActions
    @IBAction func doneButtonPressed(_ sender: Any) {
        finishOnboarding()
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func textFieldDidChange(_ textFiled: UITextField) {
        self.updateDoneButtonStatus()
    }

    //MARK: - Helper
    private func updateDoneButtonStatus() {
        if (nameTextField.text != "" && surnameTextField.text != "" && addressTextField.text != "") {
            self.doneButtonOutlet.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            self.doneButtonOutlet.isEnabled = true
        } else {
            self.doneButtonOutlet.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            self.doneButtonOutlet.isEnabled = false
        }
    }

    private func finishOnboarding() {
        let withValues = [KFIRSTNAME : nameTextField.text!, KLASTNAME : surnameTextField.text!, KONBOARD : true , KFULLADDRESS : addressTextField.text! , KFULLNAME : (nameTextField.text! + " " + surnameTextField.text!)] as [String : Any]

        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            if (error == nil) {
                self.hud.textLabel.text = "Updated!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
                
                self.dismiss(animated: true, completion: nil)
            } else {
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
        }
    }

}
