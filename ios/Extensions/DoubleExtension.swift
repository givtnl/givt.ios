//
//  DoubleExtension.swift
//  ios
//
//  Created by Mike Pattyn on 02/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

extension Double {
    func getFormattedWith(currency: String, decimals: Int, withSpace: Bool = true) -> String {
        var currency = currency
        switch currency {
        case "€":
            if withSpace {
                currency += " "
            }
        default:
            break
        }
        return "\(currency)\(String(format: "%.\(decimals)f", self))".replacingOccurrences(of: ".", with: Locale.current.decimalSeparator!)
    }
    func getFormattedWithoutCurrency(decimals: Int) -> String {
        return "\(String(format: "%.\(decimals)f", self))".replacingOccurrences(of: ".", with: Locale.current.decimalSeparator!)
    }
}
