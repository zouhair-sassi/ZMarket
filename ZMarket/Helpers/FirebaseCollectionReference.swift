//
//  FirebaseCollectionReference.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 9/22/20.
//  Copyright © 2020 Zouhair Sassi. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Category
    case Items
    case Basket
}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
