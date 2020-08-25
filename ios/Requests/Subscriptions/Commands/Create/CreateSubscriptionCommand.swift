//
//  CreateSubscriptionCommand.swift
//  ios
//
//  Created by Mike Pattyn on 28/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import CoreData

class CreateSubscriptionCommand : Codable, RequestProtocol {
    typealias TResponse = Bool
    
    var userId: UUID? = nil
    let amountPerTurn: Decimal
    let nameSpace: String
    let endsAfterTurns: Int
    let cronExpression: String
    let startDate: String
        
    internal init(amountPerTurn: Decimal, nameSpace: String, endsAfterTurns: Int, cronExpression: String, startDate: String) {
        self.amountPerTurn = amountPerTurn
        self.nameSpace = nameSpace
        self.endsAfterTurns = endsAfterTurns
        self.cronExpression = cronExpression
        self.startDate = startDate
    }
}
