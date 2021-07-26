//
//  YearlyOverviewMonthlyBarViewModel.swift
//  ios
//
//  Created by Mike Pattyn on 07/07/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class YearlyOverviewMonthlyBarViewModel {
    var givtAmount: Double = 0
    var notGivtAmount: Double = 0
    var highestAmount: Double = 0
    var maxBarWidth: CGFloat = 0
    var date: Date? = nil
    init() { }
    init(givtAmount: Double, notGivtAmount: Double, highestAmount: Double, maxBarWidth: CGFloat, date: Date) {
        self.givtAmount = givtAmount
        self.notGivtAmount = notGivtAmount
        self.highestAmount = highestAmount
        self.maxBarWidth = maxBarWidth
        self.date = date
    }
}

extension Array where Element == YearlyOverviewMonthlyBarViewModel {
    var highestBarValue: Double {
        return self.map { $0.givtAmount + $0.notGivtAmount }.max() ?? 0
    }
}
