//
//  RecurringDonationState.swift
//  ios
//
//  Created by Mike Pattyn on 09/09/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

enum RecurringDonationState : Int, Codable{
    case Cancelled = 0
    case Active = 1
    case Finished = 2
}
