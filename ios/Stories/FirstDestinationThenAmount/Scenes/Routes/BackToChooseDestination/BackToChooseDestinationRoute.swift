//
//  BackToChooseAmount.swift
//  ios
//
//  Created by Maarten Vergouwe on 21/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class BackToChooseDestinationRoute : NoResponseRequest {
    var amount: String = "0"
    
    init(amount: String) {
        self.amount = amount
    }
}
