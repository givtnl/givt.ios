//
//  CreateRecurringDonationCommand.swift
//  ios
//
//  Created by Mike Pattyn on 28/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import CoreData

class CreateRecurringDonationCommand : Codable, RequestProtocol {
    typealias TResponse = Bool
    
    var userId: UUID? = nil
    let amountPerTurn: Decimal
    let namespace: String
    let endsAfterTurns: Int
    let cronExpression: String
    let startDate: String
    var recurringDonationId: UUID? = nil
    var country: String
        
    internal init(amountPerTurn: Decimal, namespace: String, endsAfterTurns: Int, cronExpression: String, startDate: String, country: String) {
        self.amountPerTurn = amountPerTurn
        self.namespace = namespace
        self.endsAfterTurns = endsAfterTurns
        self.cronExpression = cronExpression
        self.startDate = startDate
        self.country = country
    }
}
