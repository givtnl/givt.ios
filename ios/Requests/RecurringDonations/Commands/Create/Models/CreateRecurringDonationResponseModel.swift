//
//  CreateRecurringDonationCommandResponseModel.swift
//  ios
//
//  Created by Mike Pattyn on 09/09/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

struct CreateRecurringDonationResponseModel: Codable {
    var id: String = ""
    var userID: String? = ""
    var cronExpression: String = ""
    var startDate: String = ""
    var amountPerTurn: Decimal = 0.0
    var namespace: String = ""
    var currentState: Int = 0
    var lastProcessingDate: String = ""
    var creationDateTime: String = ""
    var endsAfterTurns: Int = 0
    var turns: [RecurringTurn] = []
    var expiresAt: String?
}

struct RecurringTurn: Codable {
    var donationId: Int = 0
    var confirmationDateTime: String = ""
    var amount: Decimal = 0
}
