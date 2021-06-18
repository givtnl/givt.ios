//
//  CreateExternalDonationCommandBody.swift
//  ios
//
//  Created by Mike Pattyn on 23/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

struct CreateExternalDonationCommandBody: Codable {
    var creationDate: String
    var amount: Double
    var cronExpression: String
    var description: String
    var taxDeductable: Bool
}
