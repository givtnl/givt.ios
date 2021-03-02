//
//  NotGivtModel.swift
//  ios
//
//  Created by Mike Pattyn on 02/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

struct NotGivtModel: Codable {
    var GUID: String
    var Name: String
    var Amount: Double
    init(guid: String, name: String, amount: Double) {
        self.GUID = guid
        self.Name = name
        self.Amount = amount
    }
}
