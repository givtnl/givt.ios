//
//  PaymentTypes.swift
//  ios
//
//  Created by Lennie Stockman on 29/08/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "Use PaymentType instead")
public enum AccountType: String {
    case sepa
    case bacs
    case undefined
}
