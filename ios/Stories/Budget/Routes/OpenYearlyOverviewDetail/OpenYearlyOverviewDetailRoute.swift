//
//  OpenYearlyOverviewDetailRoute.swift
//  ios
//
//  Created by Mike Pattyn on 10/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class OpenYearlyOverviewDetailRoute: NoResponseRequest {
    var year: Int
    var givtModels: [MonthlySummaryDetailModel]
    var notGivtModels: [MonthlySummaryDetailModel]
    var fromDate: String
    var tillDate: String
    
    init(year: Int, _ givtModels: [MonthlySummaryDetailModel], _ notGivtModels: [MonthlySummaryDetailModel], _ fromDate: String, _ tillDate: String) {
        self.year = year
        self.givtModels = givtModels
        self.notGivtModels = notGivtModels
        self.fromDate = fromDate
        self.tillDate = tillDate
    }
}
