//
//  ProfileTableViewController.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 7/9/21.
//  Copyright © 2021 Zouhair Sassi. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var finishRegistrationButtonOutlet: UIButton!
    @IBOutlet weak var purchaseHistoryButtonOutlet: UIButton!

    //MARK: - Vars
    var editBarButtonOutlet: UIBarButtonItem!

    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        self.checkLoginStatus()
        self.checkOnBoardingStatus()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkOnBoardingStatus()
        self.checkLoginStatus()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    //MARK: - Helpers
    private func checkOnBoardingStatus() {
        if (MUser.currentUser() != nil) {
            if (MUser.currentUser()!.onBoard) {
                finishRegistrationButtonOutlet.setTitle("Account is Active", for: .normal)
                finishRegistrationButtonOutlet.isEnabled = false
            } else {
                finishRegistrationButtonOutlet.setTitle("Finish registration", for: .normal)
                finishRegistrationButtonOutlet.isEnabled = true
                finishRegistrationButtonOutlet.tintColor = .red
            }
            self.purchaseHistoryButtonOutlet.isEnabled = true
        } else {
            finishRegistrationButtonOutlet.setTitle("Logged out", for: .normal)
            finishRegistrationButtonOutlet.isEnabled = false
            purchaseHistoryButtonOutlet.isEnabled = false
        }
    }

    private func checkLoginStatus() {
        if (MUser.currentUser() == nil) {
            self.createRightBarButton(title: "Login")
        } else {
            self.createRightBarButton(title: "Edit")
        }
    }

    private func createRightBarButton(title: String) {
        editBarButtonOutlet = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(rightBarButtonItemPressed))
        self.navigationItem.rightBarButtonItem = editBarButtonOutlet
    }

    @objc func rightBarButtonItemPressed() {
        if (self.editBarButtonOutlet.title == "Login") {
            self.showloginView()
        } else {
            self.goToProfile()
        }
    }

    private func showloginView() {
        let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
        self.present(loginView, animated: true, completion: nil)
    }

    private func goToProfile() {
        performSegue(withIdentifier: "profileToEditSeg", sender: self)
    }
}
