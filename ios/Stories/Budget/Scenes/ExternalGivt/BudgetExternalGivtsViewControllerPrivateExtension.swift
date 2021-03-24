//
//  BudgetExternalGivtsPrivateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 01/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

private extension BudgetExternalGivtsViewController {
    @IBAction func backButton(_ sender: Any) {
        try? Mediater.shared.send(request: GoBackOneControllerRoute(), withContext: self)
    }
    
    @IBAction func buttonSave(_ sender: Any) {
        
        try? Mediater.shared.send(request: GoBackOneControllerRoute(), withContext: self)
    }

    @IBAction func timeTapped(_ sender: Any) {
        textFieldExternalGivtsTime.becomeFirstResponder()
    }
}
