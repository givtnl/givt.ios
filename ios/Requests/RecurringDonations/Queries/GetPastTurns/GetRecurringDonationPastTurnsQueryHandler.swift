//
//  GetRecurringDonationPastTurnsQueryHandler.swift
//  ios
//
//  Created by Mike Pattyn on 15/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class GetRecurringDonationPastTurnsQueryHandler : RequestHandlerProtocol {
    private var donations: [RecurringDonationTurnViewModel] = []

    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let query = request as! GetRecurringDonationPastTurnsQuery
        for donationDetail in query.details {
            let currentDay: String = donationDetail.Timestamp.toDate!.getDay().string
            let currentMonth: String = donationDetail.Timestamp.toDate!.getMonthName()
            let currentYear: String = donationDetail.Timestamp.toDate!.getYear().string
            let currentAmount = donationDetail.Amount
            let currentStatus = donationDetail.Status
            let model = RecurringDonationTurnViewModel(amount: currentAmount, day: currentDay, month: currentMonth, year: currentYear, status: currentStatus)
            donations.append(model)
        }
        try completion(donations as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GetRecurringDonationPastTurnsQuery
    }
}
