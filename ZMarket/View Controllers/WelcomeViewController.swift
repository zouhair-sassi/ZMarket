//
//  WelcomeViewController.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 1/17/21.
//  Copyright © 2021 Zouhair Sassi. All rights reserved.
//

import UIKit
import JGProgressHUD
import NVActivityIndicatorView

class WelcomeViewController: UIViewController {


    //MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var resendButtonOutlet: UIButton!

    //MARK: - vars
    let hud = JGProgressHUD(style: .dark)
    var activityIndicator: NVActivityIndicatorView?

    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.width / 2 - 30, width: 60.0, height: 60.0), type: .ballPulse, color: UIColor(red: 0.9998469949, green: 0.4941213727, blue: 0.4734867811, alpha: 1.0), padding: nil)
    }

    //MARK: IBAction
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismissView()
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        if (textFieldsHaveText()) {
            loginUser()
        } else {
            hud.textLabel.text = "All fields are required"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }

    @IBAction func registerButtonPressed(_ sender: Any) {
        if (textFieldsHaveText()) {
            registerUser()
        } else {
            hud.textLabel.text = "All fields are required"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }

    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        
    }

    //MARK: - Login User

    private func loginUser() {
        
        showLoadingIndicator()
        MUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error, isEmailVerfified) in
            if (error == nil) {
                if (isEmailVerfified) {
                    self.dismissView()
                    print("Email is verified")
                } else {
                    self.hud.textLabel.text = "Please Verify your email!"
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                }
            } else {
                self.hud.textLabel.text = error?.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
            self.hideLoadingIndicator()
        }
    }

    //Mark: - Register user

    private func registerUser() {

        showLoadingIndicator()
        MUser.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            if (error == nil) {
                self.hud.textLabel.text = "Verification Email sent!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            } else {
                self.hud.textLabel.text = error?.localizedDescription
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
            self.hideLoadingIndicator()
        }
    }

    //MARK: - Helpers
    private func textFieldsHaveText() -> Bool {
        return (emailTextField.text != "" && passwordTextField.text != "")
    }

    private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }

    //MARK: - Activity Indicator

    private func showLoadingIndicator() {

        if (activityIndicator != nil) {
            self.view.addSubview(activityIndicator!)
            activityIndicator?.startAnimating()
        }
    }

    private func hideLoadingIndicator() {
        if (activityIndicator != nil) {
            activityIndicator?.removeFromSuperview()
            activityIndicator?.stopAnimating()
        }
    }
}

