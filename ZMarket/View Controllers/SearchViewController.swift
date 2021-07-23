//
//  SearchViewController.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 7/22/21.
//  Copyright © 2021 Zouhair Sassi. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import EmptyDataSet_Swift

class SearchViewController: UIViewController {


    //MARK: - IBOutlets

    @IBOutlet weak var searchOptionsView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButtonOutlet: UIButton!

    //MARK: - Vars
    var searchResults: [Item] = []
    var activityIndicator: NVActivityIndicatorView?


    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60, height: 60), type: .ballPulse, color: .lightGray , padding: nil)
        self.searchOptionsView.isHidden = true
    }


    //MARK: - IBActions

    @IBAction func showSearchBarButtonPressed(_ sender: Any) {
        self.dismissKeyboard()
        self.showSearchField()
    }


    @IBAction func searchButtonPressed(_ sender: Any) {
        if (searchTextField.text != "") {
            self.searchInFirebase(forName: searchTextField.text!)
            self.emptyTextFiled()
            self.animateSearchOptionsIn()
            self.dismissKeyboard()
        }
    }

    //MARK: - Search database

    private func searchInFirebase(forName: String) {
        showLoadingIndicator()
        searchAlgolia(searchString: forName) { (itemIDS) in
            downloadItems(itemIDS) { (items) in
                self.searchResults = items
                self.tableView.reloadData()
                self.hideLoadingIndicator()
            }
        }
    }


    //MARK: - Helpers
    private func emptyTextFiled() {
        searchTextField.text = ""
    }

    private func dismissKeyboard() {
        self.view.endEditing(false)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        print("typing")
        searchButtonOutlet.isEnabled = textField.text != ""
        if (searchButtonOutlet.isEnabled) {
            searchButtonOutlet.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        } else {
            self.disableSearchButton()
        }
    }

    private func disableSearchButton() {
        searchButtonOutlet.isEnabled = false
        searchButtonOutlet.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    }

    private func showSearchField() {
        self.disableSearchButton()
        self.emptyTextFiled()
        self.animateSearchOptionsIn()
    }

    //MARK: - Animations

    private func animateSearchOptionsIn() {
        UIView.animate(withDuration: 0.5) {
            self.searchOptionsView.isHidden = !self.searchOptionsView.isHidden
        }
    }

    //MARK: - Activity indicator

    private func showLoadingIndicator() {
        if (activityIndicator != nil) {
            self.view.addSubview(activityIndicator!)
            self.activityIndicator?.startAnimating()
        }
    }

    private func hideLoadingIndicator() {
        if (activityIndicator != nil) {
            activityIndicator?.removeFromSuperview()
            activityIndicator?.stopAnimating()
        }
    }

    private func showItemView(withItem: Item) {
        let itemVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "itemView") as! ItemViewController
        itemVC.item = withItem
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        cell.generateCell(searchResults[indexPath.row])
        return cell
    }

    //MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.showItemView(withItem: searchResults[indexPath.row])
    }
}

extension SearchViewController: EmptyDataSetDelegate, EmptyDataSetSource {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No search results!")
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyData")
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Start searching....")
    }

    func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? {
        return UIImage(named: "search")
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        return NSAttributedString(string: "Start searching...")
    }

    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {
        self.showSearchField()
    }
}
