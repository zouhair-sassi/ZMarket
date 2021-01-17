//
//  Basket.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 1/16/21.
//  Copyright © 2021 Zouhair Sassi. All rights reserved.
//

import Foundation

class Basket {

    var id: String!
    var owerId: String!
    var itemsIds: [String]!

    init() {
    }

    init(_dictionary: NSDictionary) {
        id = _dictionary[KOBJECTID] as? String
        owerId = _dictionary[KOWNERID] as? String
        itemsIds = _dictionary[KITEMIDS] as? [String]
    }
}

//MARK: -Download items
func downloadBasketFromFirestore(_ ownerId: String, completion: @escaping (_ basket: Basket?) -> Void)  {
    FirebaseReference(.Basket).whereField(KOWNERID, isEqualTo: ownerId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {
            completion(nil)
            return
        }
        if (!snapshot.isEmpty && snapshot.documents.count > 0) {
            let basket = Basket(_dictionary: snapshot.documents.first!.data() as NSDictionary)
            completion(basket)
        } else {
            completion(nil)
        }
    }
}

//MARK: - Save to Firebase
func saveBasketTOFirestore(_ basket: Basket) {
    FirebaseReference(.Basket).document(basket.id).setData(basketDictionaryFrom(basket) as! [String: Any])
}

//MARK: Helper functions
func basketDictionaryFrom(_ basket: Basket) -> NSDictionary {
    return NSDictionary(objects: [basket.id, basket.owerId, basket.itemsIds], forKeys: [KOBJECTID as NSCopying, KOWNERID as NSCopying, KITEMIDS as NSCopying])
}

//MARK: - Updae basket
func updateBasketInFirestore(_ basket: Basket, withValues: [String : Any], completion: @escaping (_ error: Error?) -> Void) {
    FirebaseReference(.Basket).document(basket.id).updateData(withValues) { (error) in
        completion(error)
    }
}
