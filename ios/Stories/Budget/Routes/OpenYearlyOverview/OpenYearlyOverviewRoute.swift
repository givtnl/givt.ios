//
//  OpenYearlyOverviewRoute.swift
//  ios
//
//  Created by Mike Pattyn on 04/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class OpenYearlyOverviewRoute: NoResponseRequest {
    var collectGroupsForCurrentMonth: [MonthlySummaryDetailModel]
    var notGivtModelsForCurrentMonth: [ExternalDonationModel]
    
    init(_ collectGroupsForCurrentMonth: [MonthlySummaryDetailModel], _ notGivtModelsForCurrentMonth: [ExternalDonationModel]) {
        self.collectGroupsForCurrentMonth = collectGroupsForCurrentMonth
        self.notGivtModelsForCurrentMonth = notGivtModelsForCurrentMonth
    }
}
