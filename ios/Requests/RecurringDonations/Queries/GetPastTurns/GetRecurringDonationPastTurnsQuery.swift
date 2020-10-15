//
//  GetRecurringDonationPastTurnsQuery.swift
//  ios
//
//  Created by Mike Pattyn on 15/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class GetRecurringDonationPastTurnsQuery: Codable, RequestProtocol {
    typealias TResponse = [RecurringDonationTurnViewModel]
    
    var details: [DonationResponseModel]
    init(details: [DonationResponseModel]) {
        self.details = details
    }
}
