//
//  OpenSafariTransactionModel.swift
//  ios
//
//  Created by Mike Pattyn on 29/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
struct OpenSafariRouteTransactionModel : Codable {
    var Amount: Decimal
    var CollectId: String
    var Timestamp: String
    var BeaconId: String
}
