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
    typealias TResponse = ResponseModel<Bool>
    
    var userId: UUID? = nil
    
    let amountPerTurn: Decimal
    let namespace: String
    let endsAfterTurns: Int
    let startDate: String
    var country: String
    
    var recurringDonationId: UUID? = nil
    var cronExpression: String? = nil
    
    let frequency: Frequency
        
    internal init(amountPerTurn: Decimal, namespace: String, endsAfterTurns: Int, startDate: String, country: String, frequency: Frequency) {
        self.amountPerTurn = amountPerTurn
        self.namespace = namespace
        self.endsAfterTurns = endsAfterTurns
        self.startDate = startDate
        self.country = country
        self.frequency = frequency
    }
}

enum Frequency: Int, Codable {
    case Weekly = 0
    case Monthly = 1
    case ThreeMonthly = 2
    case SixMonthly = 3
    case Yearly = 4
}
