//
//  HelperFunction.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 10/3/20.
//  Copyright © 2020 Zouhair Sassi. All rights reserved.
//

import Foundation

func convertToCurrency(_ number: Double) -> String {
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = .currency
    currencyFormatter.locale = Locale.current

    return currencyFormatter.string(from: NSNumber(value: number))!
}
