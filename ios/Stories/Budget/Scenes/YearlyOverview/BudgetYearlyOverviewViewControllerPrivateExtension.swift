//
//  BudgetYearlyOverviewViewControllerPrivateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 04/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

private extension BudgetYearlyOverviewViewController {
    @IBAction func backButton(_ sender: Any) {
        try! Mediater.shared.send(request: GoBackToSummaryRoute(needsReload: false), withContext: self)
    }
    @IBAction func goToYearlyOverviewDetail(_ sender: Any) {
        trackEvent("CLICKED", properties: ["BUTTON_NAME": "DownloadYearlyOverview"])

        if !AppServices.shared.isServerReachable {
            try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
        } else {
            try? Mediater.shared.send(request: OpenYearlyOverviewDetailRoute(year: year, givtModels!, notGivtModels!, getStartDateForYear(year: year), getEndDateForYear(year: year)) , withContext: self)
        }
    }
}
