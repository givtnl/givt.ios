//
//  UpdateExternalDonationBody.swift
//  ios
//
//  Created by Mike Pattyn on 23/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

struct UpdateExternalDonationBody: Codable {
    var amount: Double
    var cronExpression: String
    var description: String
    
    init(amount: Double, cronExpression: String, description: String) {
        self.amount = amount
        self.cronExpression = cronExpression
        self.description = description
    }
}
