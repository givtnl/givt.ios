//
//  DonationResponseModel.swift
//  ios
//
//  Created by Mike Pattyn on 13/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

struct DonationResponseModel: Codable {
    let Id: Int
    let Amount: Decimal
    let OrgName: String
    let AllocationName: String?
    let CollectId: String
    let GiftAidEnabled: Bool
    let Status: Int
    let Timestamp: String
    let MediumId: String
}
