//
//  NotGivtDonationFrequency.swift
//  ios
//
//  Created by Mike Pattyn on 05/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

enum ExternalDonationFrequency: Int, Codable {
    case Once = 0
    case Monthly = 1
    case Quarterly = 2
    case HalfYearly = 3
    case Yearly = 4
}
