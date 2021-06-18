//
//  CreateExternalDonationCommand.swift
//  ios
//
//  Created by Mike Pattyn on 05/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class CreateExternalDonationCommand: RequestProtocol {
    typealias TResponse = ResponseModel<Bool>
    
    var description: String
    var amount: Double
    var frequency: ExternalDonationFrequency
    var date: Date
    var taxDeductable: Bool
    
    var cronExpression: String? = nil
    
    internal init(description: String, amount: Double, frequency: ExternalDonationFrequency, date: Date, taxDeductable: Bool) {
        self.description = description
        self.amount = amount
        self.frequency = frequency
        self.date = date
        self.taxDeductable = taxDeductable
    }
}
