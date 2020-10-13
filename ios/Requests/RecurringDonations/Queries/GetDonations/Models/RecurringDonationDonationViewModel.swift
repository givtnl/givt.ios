//
//  RecurringDonationDonationViewModel.swift
//  ios
//
//  Created by Mike Pattyn on 13/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

struct RecurringDonationDonationViewModel: Codable {
    var amount: Decimal = 0
    var confirmationDateTime: String = ""
    var donationId: Int = 0
}
