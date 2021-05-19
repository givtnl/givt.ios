//
//  ReadExternalDonationCommand.swift
//  ios
//
//  Created by Mike Pattyn on 05/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class GetAllExternalDonationsQuery: RequestProtocol {
    typealias TResponse = ExternalDonationGetAllResultModel
    
    var fromDate: String
    var tillDate: String
    
    init(fromDate: String, tillDate: String) {
        self.fromDate = fromDate
        self.tillDate = tillDate
    }
}
