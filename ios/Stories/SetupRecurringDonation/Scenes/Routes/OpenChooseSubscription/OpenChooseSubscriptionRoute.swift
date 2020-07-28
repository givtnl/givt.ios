//
//  OpenChooseSubscriptionRoute.swift
//  ios
//
//  Created by Mike Pattyn on 27/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

public class SetupRecurringDonationOpenSubscriptionRoute : NoResponseRequest {
    var name: String
    var mediumId: String
    
    init (name: String, mediumId: String) {
        self.name = name
        self.mediumId = mediumId
    }
}
