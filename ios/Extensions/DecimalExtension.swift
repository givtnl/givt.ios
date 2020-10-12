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
}
