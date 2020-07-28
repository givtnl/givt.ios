//
//  BackToChooseDestinationRoute.swift
//  ios
//
//  Created by Mike Pattyn on 27/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

public class SetupRecurringDonationBackToChooseDestinationRoute : NoResponseRequest {
    var mediumId: String
    
    init(mediumId: String) {
        self.mediumId = mediumId
    }
}
