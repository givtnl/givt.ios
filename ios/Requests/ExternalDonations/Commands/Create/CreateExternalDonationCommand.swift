//
//  CreateExternalDonationCommand.swift
//  ios
//
//  Created by Mike Pattyn on 05/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import CoreData
class CreateExternalDonationCommand: RequestProtocol {
    typealias TResponse = NSManagedObjectID
    
    var guid: String
    var name: String
    var amount: Double
    var frequency: ExternalDonationFrequency
    
    internal init(guid: String, name: String, amount: Double, frequency: ExternalDonationFrequency) {
        self.guid = guid
        self.name = name
        self.amount = amount
        self.frequency = frequency
    }
    
}
