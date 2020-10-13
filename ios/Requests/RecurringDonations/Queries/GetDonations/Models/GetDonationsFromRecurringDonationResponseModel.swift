//
//  GetDonationsFromRecurringDonationResponseModle.swift
//  ios
//
//  Created by Mike Pattyn on 13/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class GetDonationsFromRecurringDonationResponseModel: Codable {
    var count: Int
    var results: [RecurringDonationDonationViewModel]
    init(count: Int, results: [RecurringDonationDonationViewModel]){
        self.count = count
        self.results = results
    }
}
