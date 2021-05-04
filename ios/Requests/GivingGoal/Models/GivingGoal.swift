//
//  GivingGoal.swift
//  ios
//
//  Created by Mike Pattyn on 04/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

struct GivingGoal: Encodable, Decodable {
    var amount: Double
    var periodicity: Int
}
