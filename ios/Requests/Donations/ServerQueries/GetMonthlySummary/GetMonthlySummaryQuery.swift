//
//  GetMonthlySummaryQuery.swift
//  ios
//
//  Created by Mike Pattyn on 23/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class GetMonthlySummaryQuery : RequestProtocol {
    typealias TResponse = [MonthlySummaryDetailModel]
    
    var fromDate: String
    var tillDate: String
    var groupType: Int
    var orderType: Int
    
    init(fromDate: String, tillDate: String, groupType: Int, orderType: Int) {
        self.fromDate = fromDate
        self.tillDate = tillDate
        self.groupType = groupType
        self.orderType = orderType
    }
}
