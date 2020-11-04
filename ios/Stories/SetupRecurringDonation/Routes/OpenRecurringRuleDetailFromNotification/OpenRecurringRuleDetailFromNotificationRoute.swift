//
//  OpenRecurringRuleDetailFromNotificationRoute.swift
//  ios
//
//  Created by Mike Pattyn on 22/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class OpenRecurringRuleDetailFromNotificationRoute : NoResponseRequest {
    var recurringDonationId: String
    
    init(recurringDonationId: String) {
        self.recurringDonationId = recurringDonationId
    }
}
