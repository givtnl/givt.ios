//
//  CollectGroupDetailModel.swift
//  ios
//
//  Created by Maarten Vergouwe on 16/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

internal struct CollectGroupDetailModel : Codable {
    var namespace: String
    var name: String
    var type: CollectGroupType
    var paymentType: PaymentType
}
