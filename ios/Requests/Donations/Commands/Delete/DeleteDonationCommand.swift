//
//  DeleteDonationCommand.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import CoreData

class DeleteDonationCommand : NoResponseRequest {
    var objectId: NSManagedObjectID

    internal init(objectId: NSManagedObjectID) {
        self.objectId = objectId
    }
}
