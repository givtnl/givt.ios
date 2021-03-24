//
//  UpdateExternalDonationCommand.swift
//  ios
//
//  Created by Mike Pattyn on 05/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class UpdateExternalDonationCommand: RequestProtocol {
    typealias TResponse = ResponseModel<Bool>
    
    var id: String
    var amount: Double
    var cronExpression: String
    var description: String
    
    internal init(id: String,
                  amount: Double,
                  cronExpression: String,
                  description: String) {
        self.id = id
        self.amount = amount
        self.cronExpression = cronExpression
        self.description = description
    }
}
