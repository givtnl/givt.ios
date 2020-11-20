//
//  GetRecurringDonationTurnsDetailQuery.swift
//  ios
//
//  Created by Mike Pattyn on 13/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class GetDonationsByIdsQuery : Codable, RequestProtocol {
    typealias TResponse = [DonationResponseModel]
    
    var ids: [Int]
    init(ids: [Int]) {
        self.ids = ids
    }
}
