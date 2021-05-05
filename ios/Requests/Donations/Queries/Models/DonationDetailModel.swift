//
//  DonationDetailModel.swift
//  ios
//
//  Created by Maarten Vergouwe on 19/11/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import CoreData

struct DonationDetailModel {
    var objectId: NSManagedObjectID
    var mediumId: String
    var collectId: String
    var amount: Decimal
    var userId: UUID
    var timeStamp: Date
}
