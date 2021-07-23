//
//  item.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 9/29/20.
//  Copyright © 2020 Zouhair Sassi. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchClient

class Item {

    var id: String!
    var categoryId: String!
    var name: String!
    var description: String!
    var price: Double!
    var imageLinks: [String]!

    init() {
    }

    init(_dictionary: NSDictionary) {
        id = _dictionary[KOBJECTID] as? String
        categoryId = _dictionary[KCATEGORYID] as? String
        name = _dictionary[KNAME] as? String
        price = _dictionary[KPRICE] as? Double
        imageLinks = _dictionary[KIMAGELINKS] as? [String]
    }
}

//MARK: Save item func
func saveItemsToFirestore(_ item: Item) {
    FirebaseReference(.Items).document(item.id).setData(itemDictionary(item) as! [String: Any])
}

//MARK: Helper functions
func itemDictionary(_ item: Item) -> NSDictionary {
    return NSDictionary(objects: [item.id, item.categoryId, item.name, item.description, item.price, item.imageLinks], forKeys: [KOBJECTID as NSCopying, KCATEGORYID as NSCopying, KNAME as NSCopying,KDESCRIPTION as NSCopying, KPRICE as NSCopying, KIMAGELINKS as NSCopying])
}

//MARK: Download Func
func downloadItemsFromFirebase(withCategoryId: String, completion: @escaping(_ itemArray: [Item]) -> Void) {
    var itemArray: [Item] = []
    FirebaseReference(.Items).whereField(KCATEGORYID, isEqualTo: withCategoryId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {
            completion(itemArray)
            return
        }
        if !snapshot.isEmpty {
            for itemDict in snapshot.documents {
                itemArray.append(Item(_dictionary: itemDict.data() as NSDictionary))
            }
        }
        completion(itemArray)
    }
}

func downloadItems(_ withIds: [String], completion: @escaping (_ itemArray: [Item]) -> Void) {
    var count = 0
    var itemArray: [Item] = []
    if (withIds.count > 0) {
        for itemId in withIds {
            FirebaseReference(.Items).document(itemId).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else {
                    completion(itemArray)
                    return
                }
                if (snapshot.exists) {
                    itemArray.append(Item(_dictionary: snapshot.data()! as NSDictionary))
                    count += 1

                } else {
                    completion(itemArray)
                }
                if count == withIds.count {
                    completion(itemArray)
                }
            }
        }
    } else {
        completion(itemArray)
    }

}

//MARK: - Algolia Funcs

func saveItemToAlgolia(item: Item) {
    let index = AlgoliaService.shared.index
    let itemToSave = itemDictionary(item) as! [String : Any]
    index.addObject(itemToSave, withID: item.id, requestOptions: nil) { (content, error) in
        if (error != nil) {
            print("error saving to algolia", error!.localizedDescription)
        } else{
            print("added to algolia")
        }
    }
}

func searchAlgolia(searchString: String, completion: @escaping (_ itemArray: [String]) -> Void) {
    let index = AlgoliaService.shared.index
    var resultIds: [String] = []
    let query = Query(query: searchString)
    query.attributesToRetrieve = ["name", "description"]
    index.search(query) { (content, error) in
        if (error == nil) {
            let cont = content!["hits"] as! [[String: Any]]
            resultIds = []
            for result in cont {
                resultIds.append(result["objectID"] as! String)
            }
            completion(resultIds)
        } else {
            print("Error algolia search", error!.localizedDescription)
            completion(resultIds)
        }
    }
}
