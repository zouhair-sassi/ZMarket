//
//  AlgoliaService.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 7/23/21.
//  Copyright © 2021 Zouhair Sassi. All rights reserved.
//

import Foundation
import InstantSearchClient

class AlgoliaService {

    static let shared = AlgoliaService()

    let client = Client(appID: algoliaAppID, apiKey: algoliaAdminKey)
    let index = Client(appID: algoliaAppID, apiKey: algoliaAdminKey).index(withName: "item_Name")
    private init() {}
}

