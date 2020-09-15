//
//  SetupRecurringDonationChooseDestinationRoute.swift
//  ios
//
//  Created by Jonas Brabant on 28/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

public class SetupRecurringDonationChooseDestinationRoute : NoResponseRequest {
    var mediumId: String
    
    init(mediumId: String) {
        self.mediumId = mediumId
    }
}
