//
//  CancelRecurringDonationCommand.swift
//  ios
//
//  Created by Mike Pattyn on 07/09/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
class CancelRecurringDonationCommand : Codable, RequestProtocol {
    typealias TResponse = Bool
    
    let recurringDonationId: String
    internal init(recurringDonationId: String) {
        self.recurringDonationId = recurringDonationId
    }
}
