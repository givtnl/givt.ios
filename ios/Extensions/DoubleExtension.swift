//
//  DoubleExtension.swift
//  ios
//
//  Created by Mike Pattyn on 02/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

extension Double {
    func toPercentile(decimals: Int = 0, showSign: Bool = false) -> String {
        var sign = ""
        if self > 0 && showSign {
            sign = "+"
        }
        return "\(sign)\(String(format: "%.\(decimals)f", self))%".replacingOccurrences(of: ".", with: Locale.current.decimalSeparator!)
    }
    var toFloat: Float {
        return Float(self)
    }
    
    func getFormattedWithoutCurrency(decimals: Int) -> String {
        return "\(String(format: "%.\(decimals)f", self))".replacingOccurrences(of: ".", with: Locale.current.decimalSeparator!)
    }
}
