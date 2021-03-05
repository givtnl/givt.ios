//
//  DeleteExternalDonationCommand.swift
//  ios
//
//  Created by Mike Pattyn on 05/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import CoreData

class DeleteExternalDonationCommand: RequestProtocol {
    typealias TResponse = NSManagedObjectID
    
    var guid: String
    
    internal init(guid: String) {
        self.guid = guid
    }
}
