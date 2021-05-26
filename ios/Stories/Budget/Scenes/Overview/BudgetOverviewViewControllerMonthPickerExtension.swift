//
//  BudgetOverviewViewControllerMonthPickerExtension.swift
//  ios
//
//  Created by Mike Pattyn on 26/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension BudgetOverviewViewController {
    func setupMonthPicker() {
        monthPickerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openMonthPicker)))
    }
    
    @objc private func openMonthPicker() {
        print("press works")
    }
    
    private func getAllMonthsOfYear() -> [String] {
        let calendar = Calendar.current
        let months = calendar.monthSymbols
        return months
    }
}
