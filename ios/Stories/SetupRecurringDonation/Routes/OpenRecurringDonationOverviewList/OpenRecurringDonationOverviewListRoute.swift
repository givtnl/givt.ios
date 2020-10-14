//
//  OpenRecurringDonationOverviewList.swift
//  ios
//
//  Created by Mike Pattyn on 13/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class OpenRecurringDonationOverviewListRoute: NoResponseRequest {
    var recurringDonation: RecurringRuleViewModel
    
    init(recurringDonation: RecurringRuleViewModel) {
        self.recurringDonation = recurringDonation
    }
}
