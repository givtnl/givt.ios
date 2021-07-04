//
//  BudgetYearlyOverviewViewControllerMonthlyBarsExtension.swift
//  ios
//
//  Created by Mike Pattyn on 03/07/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class MonthlyBarViewModel {
    var givtAmount: Double
    var notGivtAmount: Double
    var highestAmount: Double
    var maxBarWidth: Double
    var date: Date
    init(givtAmount: Double, notGivtAmount: Double, highestAmount: Double, maxBarWidth: Double, date: Date) {
        self.givtAmount = givtAmount
        self.notGivtAmount = notGivtAmount
        self.highestAmount = highestAmount
        self.maxBarWidth = maxBarWidth
        self.date = date
    }
}

extension BudgetYearlyOverviewViewController {
    func loadbars(barz: [MonthlyBarViewModel]) {
        for int in 0...barz.count - 1 {
            let monthlyBar = YearlyOverviewMonthlyBar()
            monthlyBar.tag = int
            monthlyBarsStackView.addArrangedSubview(monthlyBar)
            monthlyBarsStackViewHeight.constant += 25
            monthlyBar.monthlyBarViewModel = barz[int]
        }
        
    }
}
