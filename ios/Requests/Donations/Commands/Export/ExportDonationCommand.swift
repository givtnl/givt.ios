//
//  ExportDonationCommand.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class ExportDonationCommand : RequestProtocol {
    typealias TResponse = Bool
    
    var mediumId: String
    var amount: Decimal
    var userId: UUID
    var timeStamp: Date
    var collectId: String
    
    internal init(mediumId: String, collectId: String, amount: Decimal, userId: UUID, timeStamp: Date) {
        self.mediumId = mediumId
        self.collectId = collectId
        self.amount = amount
        self.userId = userId
        self.timeStamp = timeStamp
    }
}
