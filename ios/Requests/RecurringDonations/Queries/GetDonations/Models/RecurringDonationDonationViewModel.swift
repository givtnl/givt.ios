//
//  RecurringDonationDonationViewModel.swift
//  ios
//
//  Created by Mike Pattyn on 13/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

public class RecurringDonationDonationViewModel: Codable {
    var id: String
    var amount: Decimal
    var confirmationDateTime: Date
    init(id: String, amount: Decimal, confirmationDateTime: Date) {
        self.id = id
        self.amount = amount
        self.confirmationDateTime = confirmationDateTime
    }
}
