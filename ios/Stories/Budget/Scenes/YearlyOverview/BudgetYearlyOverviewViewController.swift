//
//  BudgetYearlyOverviewViewController.swift
//  ios
//
//  Created by Mike Pattyn on 04/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class BudgetYearlyOverviewViewController: UIViewController {
    @IBOutlet weak var navItem: UINavigationItem!
    
    var collectGroupsForCurrentMonth: [MonthlySummaryDetailModel]!
    var notGivtModelsForCurrentMonth: [ExternalDonationModel]!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
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
