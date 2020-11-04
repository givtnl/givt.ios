//
//  DiscoverOrAmountSetupSingleDonationRoute.swift
//  ios
//
//  Created by Mike Pattyn on 29/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

public class DiscoverOrAmountOpenSetupSingleDonationRoute : NoResponseRequest {
    var name: String
    var mediumId: String
    
    init (name: String, mediumId: String) {
        self.name = name
        self.mediumId = mediumId
    }
}
