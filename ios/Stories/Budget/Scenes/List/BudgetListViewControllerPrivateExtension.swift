//
//  BudgetListViewControllerPrivateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 29/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

extension BudgetListViewController {
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismissOverlay()
        try? Mediater.shared.send(request: OpenExternalGivtsRoute(), withContext: self)
    }
}
