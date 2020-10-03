//
//  ItemsTableViewController.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 9/29/20.
//  Copyright © 2020 Zouhair Sassi. All rights reserved.
//

import UIKit

class ItemsTableViewController: UITableViewController {

    //MARK: vars
    var category: Category?
    var itemArray: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        //tableView.register(ItemTableViewCell.self, forCellReuseIdentifier: "Cell")
        self.title = category?.name
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if category != nil {
            loadItems()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        cell.generateCell(itemArray[indexPath.row])
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "itemToAddItemSeg" {
            let vc = segue.destination as! AddItemViewController
            vc.category = category!
        }
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