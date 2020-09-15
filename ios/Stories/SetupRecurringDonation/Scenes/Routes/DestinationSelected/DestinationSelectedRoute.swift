//
//  OpenChooseRecurringDonationRoute.swift
//  ios
//
//  Created by Mike Pattyn on 27/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

public class DestinationSelectedRoute : NoResponseRequest {
    var name: String
    var mediumId: String
    var orgType: CollectGroupType
    
    init (name: String, mediumId: String, orgType: CollectGroupType) {
        self.name = name
        self.mediumId = mediumId
        self.orgType = orgType
    }
}
