//
//  RecurringDonationTurnViewModel.swift
//  ios
//
//  Created by Mike Pattyn on 13/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

struct RecurringDonationTurnViewModel {
    var amount: Decimal
    var day: String
    var month: String
    var year: String
    var status: Int
    var toBePlanned: Bool;
    var isGiftAided: Bool? = false;
}
