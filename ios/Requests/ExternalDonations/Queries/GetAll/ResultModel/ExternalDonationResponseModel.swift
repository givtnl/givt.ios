//
//  ExternalDonationResponseModel.swift
//  ios
//
//  Created by Mike Pattyn on 23/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

struct ExternalDonationGetAllResultModel: Codable {
    var result: Array<ExternalDonationModel>
    init(result: Array<ExternalDonationModel>) {
        self.result = result
    }
}
