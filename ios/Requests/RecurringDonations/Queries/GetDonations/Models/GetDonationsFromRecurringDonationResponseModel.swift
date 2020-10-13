//
//  GetDonationsFromRecurringDonationResponseModle.swift
//  ios
//
//  Created by Mike Pattyn on 13/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

struct GetDonationsFromRecurringDonationResponseModel: Codable {
    public var count: Int = 0
    public var results: [RecurringDonationDonationViewModel] = []
}
