//
//  ItemViewController.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 11/24/20.
//  Copyright © 2020 Zouhair Sassi. All rights reserved.
//

import UIKit
import JGProgressHUD

class ItemViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!

    //MARK: - Vars
    var item: Item!
    var itemImages: [UIImage] = []
    let hud = JGProgressHUD(style: .dark)
    
    private let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    private let cellHeight: CGFloat = 196.0
    private let itemsPerRow: CGFloat = 0


    //MARK: - ViewLifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        downloadPictures()
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.backAction))]
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "addToBasket"), style: .plain, target: self, action: #selector(self.addToBasketButtonPressed))]
    }

    //MARK: - Download Pictures
    private func downloadPictures() {
        if item != nil && item.imageLinks != nil {
            downloadImages(imageUrls: item.imageLinks) { (allImages) in
                if allImages.count > 0 {
                    self.itemImages = allImages as! [UIImage]
                    self.imageCollectionView.reloadData()
                }
            }
        }
    }

    //MARK: - Setup UI
    private func setupUI() {
        if item != nil {
            self.title = item.name
            nameLabel.text = item.name
            priceLabel.text = convertToCurrency(item.price)
            descriptionTextView.text = item.description
        }
    }

    //MARK: - IBActions
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func addToBasketButtonPressed() {
        //TODO: check if user is logged in or show login view
        downloadBasketFromFirestore("123") { (basket) in
            if (basket == nil) {
                self.createNewBasket()
            } else {
                basket!.itemsIds.append(self.item.id)
                self.updateBasket(basket: basket!, withValues: [KITEMIDS : basket?.itemsIds])
            }
        }
    }

    //MARK: Add to basket
    private func createNewBasket() {
        let newBasket = Basket()
        newBasket.id = UUID().uuidString
        newBasket.owerId = "123"
        newBasket.itemsIds = [self.item.id]
        saveBasketTOFirestore(newBasket)

        self.hud.textLabel.text = "Added to basket!"
        self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        self.hud.show(in: self.view)
        self.hud.dismiss(afterDelay: 2.0)
    }

    private func updateBasket(basket: Basket, withValues: [String: Any]) {
        updateBasketInFirestore(basket, withValues: withValues) { (error) in
            if (error != nil) {
                self.hud.textLabel.text = "Error: \(error!.localizedDescription)"
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)

                print("error updating basket", error!.localizedDescription)
            } else {
                self.hud.textLabel.text = "Added to basket!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
        }
    }
}

extension ItemViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemImages.count == 0 ? 1 : itemImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCollectionViewCell
        if itemImages.count > 0 {
            cell.setupImageWidth(itemImage: itemImages[indexPath.row])

        }
        return cell
    }
}

extension ItemViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let availableWidth = collectionView.frame.width - sectionInsets.left
        return CGSize(width: availableWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

