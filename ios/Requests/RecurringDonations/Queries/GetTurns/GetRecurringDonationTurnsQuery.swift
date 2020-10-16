//
//  GetDonationsFromRecurringDonationQuery.swift
//  ios
//
//  Created by Mike Pattyn on 13/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

class GetRecurringDonationTurnsQuery : Codable, RequestProtocol {
    typealias TResponse = [Int]
    var id: String
    init(id: String){
        self.id = id
    }
}
