//
//  DecimalExtension.swift
//  ios
//
//  Created by Mike Pattyn on 28/09/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation


extension Decimal {
    
    var int: Int {
        return NSDecimalNumber(decimal: self).intValue
    }
    
    var formattedTwoDigits: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(for: self)
    }
}
