//
//  MonthlySummaryDetailModel.swift
//  ios
//
//  Created by Mike Pattyn on 23/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

struct MonthlySummaryDetailModel: Codable {
    let Key: String
    let Value: Double
    let Count: Double
    let TaxDeductable: Bool?
}
