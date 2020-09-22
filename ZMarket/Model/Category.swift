//
//  Category.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 9/22/20.
//  Copyright © 2020 Zouhair Sassi. All rights reserved.
//

import Foundation
import UIKit

class Category {

    var id: String
    var name: String
    var image: UIImage?
    var imageName: String?

    init(_name: String, _imageName: String) {

        id = ""
        name = _name
        imageName = _imageName
        image = UIImage(named: _imageName)
    }

    init(_dictionary: NSDictionary) {
        id = _dictionary[KOBJECTID] as! String
        name = _dictionary[KNAME] as! String
        image = UIImage(named: _dictionary[KIMAGENAME] as? String ?? "")
    }
}


//MARK: Save category function

func saveCategoryToFirebase(_ category: Category) {
    let id = UUID().uuidString
    category.id = id
    FirebaseReference(.Category).document(id).setData(categoryDictonaryForm(category) as! [String : Any])
}

//MARK: Helpers

func categoryDictonaryForm(_ category: Category) -> NSDictionary {
    return NSDictionary(objects: [category.id, category.name, category.imageName], forKeys:[KOBJECTID as NSCopying, KNAME as NSCopying, KIMAGENAME as NSCopying])
}

//use only one time
func createCategorySet() {

    let womenClothing = Category(_name: "Women's Clothing & Accessories", _imageName: "womenCloth")
    let footWaer = Category(_name: "Footwaer", _imageName: "footWaer")
    let electronics = Category(_name: "Electronics", _imageName: "electronics")
    let menClothing = Category(_name: "Men's Clothing & Accessories" , _imageName: "menCloth")
    let health = Category(_name: "Health & Beauty", _imageName: "health")
    let baby = Category(_name: "Baby Stuff", _imageName: "baby")
    let home = Category(_name: "Home & Kitchen", _imageName: "home")
    let car = Category(_name: "Automobiles & Motorcyles", _imageName: "car")
    let luggage = Category(_name: "Luggage & bags", _imageName: "luggage")
    let jewelery = Category(_name: "Jewelery", _imageName: "jewelery")
    let hobby =  Category(_name: "Hobby, Sport, Traveling", _imageName: "hobby")
    let pet = Category(_name: "Pet products", _imageName: "pet")
    let industry = Category(_name: "Industry & Business", _imageName: "industry")
    let garden = Category(_name: "Garden supplies", _imageName: "garden")
    let camera = Category(_name: "Cameras & Optics", _imageName: "camera")

    let arrayOfCategories = [womenClothing, footWaer, electronics, menClothing, health, baby, home, car, luggage, jewelery, hobby, pet, industry, garden, camera]

    for category in arrayOfCategories {
        saveCategoryToFirebase(category)
    }

}
