//
//  UpdateExternalDonationBody.swift
//  ios
//
//  Created by Mike Pattyn on 23/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

struct UpdateExternalDonationBody: Codable {
    var cronExpression: String
    var description: String
    var amount: Double

    init(cronExpression: String, description: String, amount: Double) {
        self.cronExpression = cronExpression
        self.description = description
        self.amount = amount
    }
}
