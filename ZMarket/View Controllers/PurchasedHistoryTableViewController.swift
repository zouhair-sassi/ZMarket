//
//  PurchasedHistoryTableViewController.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 7/16/21.
//  Copyright © 2021 Zouhair Sassi. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class PurchasedHistoryTableViewController: UITableViewController {

    //MARK: - Vars
    var itemsArray : [Item] = []

    //MARK: - Views Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadItems()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return itemsArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        cell.generateCell(itemsArray[indexPath.row])

        return cell
    }

    //MARK: - Load items
    private func loadItems() {
        downloadItems(MUser.currentUser()!.purchasedItemIds) { (items) in
            self.itemsArray = items
            print("we have \(items.count) pusrshed items")
            self.tableView.reloadData()
        }
    }
}

extension PurchasedHistoryTableViewController: EmptyDataSetDelegate, EmptyDataSetSource {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No items to display!")
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyData")
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Please check back later")
    }
}
