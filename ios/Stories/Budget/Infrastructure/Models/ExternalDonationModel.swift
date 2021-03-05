//
//  ExternalDonationModel.swift
//  ios
//
//  Created by Mike Pattyn on 05/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import CoreData

struct ExternalDonationModel {
    var objectId: NSManagedObjectID
    var guid: String
    var name: String
    var amount: Double
    var frequency: ExternalDonationFrequency
    
    init(objectId: NSManagedObjectID, guid: String, name: String, amount: Double, frequency: ExternalDonationFrequency) {
        self.objectId = objectId
        self.guid = guid
        self.name = name
        self.amount = amount
        self.frequency = frequency
    }
}
