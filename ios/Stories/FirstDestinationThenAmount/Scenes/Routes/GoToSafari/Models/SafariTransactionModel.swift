//
//  SafariTransactionModel.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

struct SafariTransactionModel : Codable {
    var Amount: Decimal
    var CollectId: String
    var Timestamp: String
    var BeaconId: String
}
