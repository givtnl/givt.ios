//
//  OpenSummaryRoute.swift
//  ios
//
//  Created by Mike Pattyn on 15/04/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class OpenSummaryRoute: NoResponseRequest {
    var fromDate: Date
    var openYearlyOverview: Bool
    init(fromDate: Date, openYearlyOverview: Bool = false) {
        self.fromDate = fromDate
        self.openYearlyOverview = openYearlyOverview
    }
}
