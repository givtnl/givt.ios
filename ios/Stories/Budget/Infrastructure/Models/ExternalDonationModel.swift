//
//  ExternalDonationModel.swift
//  ios
//
//  Created by Mike Pattyn on 05/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import CoreData

struct ExternalDonationModel: Codable {
    var id: String
    var amount: Double
    var description: String
    var cronExpression: String
    var creationDate: String
    var taxDeductable: Bool
    
    init(id: String, amount: Double, description: String, cronExpression: String, creationDate: String, taxDeductable: Bool) {
        self.id = id
        self.amount = amount
        self.description = description
        self.cronExpression = cronExpression
        self.creationDate = creationDate
        self.taxDeductable = taxDeductable
    }
}
