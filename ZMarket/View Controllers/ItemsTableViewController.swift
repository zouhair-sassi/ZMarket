//
//  ItemsTableViewController.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 9/29/20.
//  Copyright © 2020 Zouhair Sassi. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class ItemsTableViewController: UITableViewController {

    //MARK: vars
    var category: Category?
    var itemArray: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.title = category?.name
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if category != nil {
            loadItems()
        }
    }

    //MARK: - TableView data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        cell.generateCell(itemArray[indexPath.row])
        return cell
    }

    //MARK: - TableView delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(itemArray[indexPath.row])
    }

    //MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "itemToAddItemSeg" {
            let vc = segue.destination as! AddItemViewController
            vc.category = category!
        }
    }
    private func showItemView(_ item: Item) {
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "itemView") as! ItemViewController
        itemVC.item = item
        self.navigationController?.pushViewController(itemVC, animated: true)
    }

    //MARK: Load Items
    private func loadItems() {
        downloadItemsFromFirebase(withCategoryId: category!.id) { (items) in
            print("we have all items \(items.count)")
            self.itemArray = items
            self.tableView.reloadData()
        }
    }
}

extension ItemsTableViewController: EmptyDataSetDelegate, EmptyDataSetSource {

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
