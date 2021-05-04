//
//  BudgetGivingGoalViewControllerPrivateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 04/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

private extension BudgetGivingGoalViewController {
    @IBAction func backButton(_ sender: Any) {
        try? Mediater.shared.send(request: GoBackOneControllerRoute(), withContext: self)
    }
    
    @IBAction func buttonSave(_ sender: Any) {
        print("Save")
    }
}
