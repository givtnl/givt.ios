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
    
    init(year: Int, _ givtModels: [MonthlySummaryDetailModel], _ notGivtModels: [MonthlySummaryDetailModel]) {
        self.year = year
        self.givtModels = givtModels
        self.notGivtModels = notGivtModels
    }
}
