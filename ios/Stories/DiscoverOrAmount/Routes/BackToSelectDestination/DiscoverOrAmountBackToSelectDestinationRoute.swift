//
//  DiscoverOrAmountBackToSelectDestinationRoute.swift
//  ios
//
//  Created by Mike Pattyn on 29/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
class DiscoverOrAmountBackToSelectDestinationRoute : NoResponseRequest {
    var amount: String = "0"
    
    init(amount: String) {
        self.amount = amount
    }
}
