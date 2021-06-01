//
//  BudgetListViewControllerPrivateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 29/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

extension BudgetListViewController {
    @IBAction func manageExternalDonations(_ sender: Any) {
        dismissOverlay()
        NavigationManager.shared.executeWithLogin(context: self) {
            try? Mediater.shared.send(request: OpenExternalGivtsRoute(externalDonations: self.notGivtModelsForCurrentMonth), withContext: self)
        }
    }
}
