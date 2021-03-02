//
//  DoubleExtension.swift
//  ios
//
//  Created by Mike Pattyn on 02/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

extension Double {
    func getFormattedWith(currency: String, decimals: Int) -> String {
        var currency = currency
        switch currency {
        case "€":
            currency += " "
        default:
            break
        }
        return "\(currency)\(String(format: "%.\(decimals)f", self))".replacingOccurrences(of: ".", with: Locale.current.decimalSeparator!)
    }
}
