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
        if !AppServices.shared.isServerReachable {
            try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
        } else {
            NavigationManager.shared.executeWithLogin(context: self) {
                try! Mediater.shared.send(request: GoBackToSummaryRoute(needsReload: false), withContext: self)
            }
        }
    }
}
