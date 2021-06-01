//
//  OpenExternalGivtsRoute.swift
//  ios
//
//  Created by Mike Pattyn on 27/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import CoreData

class OpenExternalGivtsRoute: NoResponseRequest {
    var id: String?
    var externalDonations: [ExternalDonationModel]?
    
    init(id: String? = nil, externalDonations: [ExternalDonationModel]? = nil) {
        self.id = id
        self.externalDonations = externalDonations
    }
}
