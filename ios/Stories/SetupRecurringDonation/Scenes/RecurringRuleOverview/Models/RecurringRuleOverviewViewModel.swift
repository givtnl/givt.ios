//
//  RecurringRuleOverviewViewModel.swift
//  ios
//
//  Created by Jonas Brabant on 14/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

struct RecurringRuleOverviewViewModel: Codable {
    var amount: Decimal = 0
    var confirmationDateTime: String = ""
    var donationId: Int = 0
}
