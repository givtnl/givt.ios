//
//  BackToChooseDestinationRoute.swift
//  ios
//
//  Created by Mike Pattyn on 27/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class SetupRecurringDonationBackToChooseDestinationRoute : NoResponseRequest {
    var amount: String = "0"
    
    init(amount: String) {
        self.amount = amount
    }
}
