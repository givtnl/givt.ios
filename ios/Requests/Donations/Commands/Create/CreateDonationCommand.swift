//
//  CreateDonationCommand.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import CoreData

class CreateDonationCommand: RequestProtocol {
    typealias TResponse = NSManagedObjectID
    
    var mediumId: String
    var amount: Decimal
    var userId: UUID
    var timeStamp: Date
    var collectId: String
    
    internal init(mediumId: String, amount: Decimal, userId: UUID, timeStamp: Date, collectId: String) {
        self.mediumId = mediumId
        self.amount = amount
        self.userId = userId
        self.timeStamp = timeStamp
        self.collectId = collectId
    }
}
