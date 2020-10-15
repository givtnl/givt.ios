//
//  GetRecurringDonationFutureTurnsQuery.swift
//  ios
//
//  Created by Mike Pattyn on 15/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class GetRecurringDonationFutureTurnsQuery: Codable, RequestProtocol {
    typealias TResponse = [RecurringDonationTurnViewModel]
    
    
    var recurringDonation: RecurringRuleViewModel
    var recurringDonationLastTurn: DonationResponseModel
    var recurringDonationPastTurnsCount: Int
    
    init(recurringDonation: RecurringRuleViewModel, recurringDonationLastTurn: DonationResponseModel, recurringDonationPastTurnsCount: Int) {
        self.recurringDonation = recurringDonation
        self.recurringDonationLastTurn = recurringDonationLastTurn
        self.recurringDonationPastTurnsCount = recurringDonationPastTurnsCount
    }
}
