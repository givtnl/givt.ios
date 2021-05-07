//
//  BudgetViewControllerYearlyChartExtension.swift
//  ios
//
//  Created by Mike Pattyn on 01/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import Charts
import UIKit
class YearlySummaryItem {
    var year: Int
    var amount: Double
    init(year: Int, amount: Double) {
        self.year = year
        self.amount = amount
    }
}

// MARK: VC Extension With Year chart functions
extension BudgetOverviewViewController {
    func setupYearsCard() {
        var yearsWithValues: [YearlySummaryItem] = []
        
        let currentYear = Date().getYear().string.toInt
        yearsWithValues.append(YearlySummaryItem(year: currentYear-1, amount: 0))
        yearsWithValues.append(YearlySummaryItem(year: currentYear, amount: 0))
                
        let fromDate = getFromDateForYearlyOverview()
        let tillDate = getTillDateForCurrentMonth()
        
        let yearlySummary: [MonthlySummaryDetailModel] = try! Mediater.shared.send(request: GetMonthlySummaryQuery(
                                                                                    fromDate: fromDate,
                                                                                    tillDate: tillDate,
                                                                                    groupType: 1,
                                                                                    orderType: 0))
        
        yearlySummary.forEach { model in
            let item = yearsWithValues.first { $0.year == model.Key.toInt }
            item?.amount = model.Value
        }
        
        let yearlySummaryNotGivt: [MonthlySummaryDetailModel] = try! Mediater.shared.send(request: GetExternalMonthlySummaryQuery(
                                                                                            fromDate: fromDate,
                                                                                            tillDate: tillDate,
                                                                                            groupType: 1,
                                                                                            orderType: 0))
        
        yearlySummaryNotGivt.forEach { model in
            let item = yearsWithValues.first { $0.year == model.Key.toInt }
            item?.amount += model.Value
        }
        
        let referenceValue = yearsWithValues.max { val1, val2 in val1.amount < val2.amount }!
        // get biggest value that will be equal to max width
//        let referenceValueItem: [String: Double]? = testValues.count > 0 ? highestTestValue! : nil
        // get max width from superview
        let maxWidth = yearBarOneParent.frame.width
        // grootstn  = maxWidth
        let barOneConstraint = yearBarOne.constraints.first { constraint in constraint.identifier == "IdYearBarOne" }
        let barTwoConstraint = yearBarTwo.constraints.first { constraint in constraint.identifier == "IdYearBarTwo" }
        
        let lowestYear = yearsWithValues.min(by: { val1, val2 in val1.year < val2.year })!
        let lowestYearValue = lowestYear.amount / referenceValue.amount
        
        let highestYear = yearsWithValues.max { val1, val2 in val1.year < val2.year }!
        let highestYearValue = highestYear.amount / referenceValue.amount
        
        barOneConstraint?.constant = maxWidth * CGFloat(lowestYearValue.isFinite ? lowestYearValue : 0)
        barTwoConstraint?.constant = maxWidth * CGFloat(highestYearValue.isFinite ? highestYearValue : 0)
        
        yearBarOneLabel.text = lowestYear.year.string
        yearBarTwoLabel.text = highestYear.year.string
        
        [yearBarOne.amountLabel, yearBarOneOutsideValueLabel].forEach({ label in
            label.text = lowestYear.amount.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
        })
        
        [yearBarTwo.amountLabel, yearBarTwoOutsideValueLabel].forEach({ label in
            label.text = highestYear.amount.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
        })
        
        if barOneConstraint!.constant-30 <= yearBarOne.amountLabel.frame.width {
            yearBarOne.amountLabel.isHidden = true
            if lowestYearValue.isFinite {
                yearBarOneOutsideValueLabel.isHidden = false
            }
        }
        
        if barTwoConstraint!.constant-30 <= yearBarTwo.amountLabel.frame.width {
            yearBarTwo.amountLabel.isHidden = true
            if highestYearValue.isFinite {
                yearBarTwoOutsideValueLabel.isHidden = false
            }
        }
        
        yearBarOne.bgView.backgroundColor = ColorHelper.SoftenedGivtPurple
        yearBarOneOutsideValueLabel.textColor = ColorHelper.SoftenedGivtPurple
        
        yearBarTwo.bgView.backgroundColor = ColorHelper.GivtLightGreen
        yearBarTwoOutsideValueLabel.textColor = ColorHelper.GivtLightGreen
        
        if yearsWithValues.filter({ $0.amount == 0.0 }).count == 2 {
            yearBarOneStackItem.removeFromSuperview()
        } else if yearsWithValues.filter({ $0.amount == 0.0 }).count == 1 {
            let emptyYear = yearsWithValues.first { item in item.amount == 0.0 }
            if emptyYear!.year == currentYear - 1 {
                yearBarOneStackItem.removeFromSuperview()
            }
        }
    }
    
    private func getFromDateForYearlyOverview() -> String {
        var componentsForYearlySummaryComponents = DateComponents()
        componentsForYearlySummaryComponents.day = 1
        componentsForYearlySummaryComponents.month = 1
        componentsForYearlySummaryComponents.year = Calendar.current.component(.year, from: Date()) - 1
        let date = Calendar.current.date(from: componentsForYearlySummaryComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}
