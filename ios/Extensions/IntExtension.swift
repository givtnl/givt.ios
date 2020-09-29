//
//  IntExtension.swift
//  ios
//
//  Created by Mike Pattyn on 28/09/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
extension Int {
    var decimal: Decimal {
        return Decimal(self)
    }
    var string: String {
        return String(self)
    }
}
