//
//  DonationError.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

enum DonationError : Error {
    case amountTooHigh
    case amountTooLow
}
