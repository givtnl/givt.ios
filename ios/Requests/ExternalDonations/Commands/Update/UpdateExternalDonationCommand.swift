//
//  UpdateExternalDonationCommand.swift
//  ios
//
//  Created by Mike Pattyn on 05/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import CoreData

class UpdateExternalDonationCommand: RequestProtocol {
    typealias TResponse = NSManagedObjectID
    
    var externalDonation: ExternalDonationModel
    
    internal init(externalDonation: ExternalDonationModel) {
        self.externalDonation = externalDonation
    }
}
