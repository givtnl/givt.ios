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
        
        guard let yearlySummary = yearlySummary else {
            return
        }
        
        yearlySummary.forEach { model in
            let item = yearsWithValues.first { $0.year == model.Key.toInt }
            item?.amount = model.Value
        }
        
        guard let yearlySummaryNotGivt = yearlySummaryNotGivt else {
            return
        }
        
        yearlySummaryNotGivt.forEach { model in
            let item = yearsWithValues.first { $0.year == model.Key.toInt }
            item?.amount += model.Value
        }
        
        let regularReferenceValue = yearsWithValues.max { val1, val2 in val1.amount < val2.amount }!.amount
        
        let givingGoalReferenceValue = givingGoal != nil ? givingGoal!.periodicity == 1 ? givingGoal!.amount : givingGoal!.amount * 12 : 0.0
        
        let referenceValue = regularReferenceValue > givingGoalReferenceValue ? regularReferenceValue : givingGoalReferenceValue
        
        let maxWidth = yearBarOneParent.frame.width
        
        var barOneConstraint: NSLayoutConstraint? = nil
        
        if yearBarOne != nil {
            barOneConstraint = yearBarOne.constraints.first { constraint in constraint.identifier == "IdYearBarOne" }
            
            let lowestYear = yearsWithValues.min(by: { val1, val2 in val1.year < val2.year })!
            let lowestYearValue = lowestYear.amount / referenceValue
            
            barOneConstraint?.constant = maxWidth * CGFloat(lowestYearValue.isFinite ? lowestYearValue : 0)
            
            yearBarOneLabel.text = lowestYear.year.string
            
            [yearBarOne.amountLabel, yearBarOneOutsideValueLabel].forEach({ label in
                label.text = lowestYear.amount.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
            })
            
            let barOneWidth = barOneConstraint!.constant-30
            let labelWidth = yearBarOne.amountLabel.frame.width
            
            self.view.layoutIfNeeded()
            
            if givingGoal == nil {
                if barOneWidth <= labelWidth {
                    yearBarOne.amountLabel.isHidden = true
                    if lowestYearValue.isFinite {
                        yearBarOneOutsideValueLabel.isHidden = false
                    }
                }
            }
            yearBarOne.amountLabelOutside.isHidden = true
            yearBarOne.amountLabel.leadingAnchor.constraint(equalTo: yearBarOne.givenAmountView.trailingAnchor, constant: 0).isActive = true

            yearBarOne.bgView.backgroundColor = ColorHelper.SoftenedGivtPurple
            yearBarOneOutsideValueLabel.textColor = ColorHelper.SoftenedGivtPurple
        }
        let barTwoConstraint = yearBarTwo.constraints.first { constraint in constraint.identifier == "IdYearBarTwo" }
        let otherConstraint = yearBarTwo.givenAmountView.constraints.first { constraint in constraint.identifier == "OverlaySpecial" }
        let highestYear = yearsWithValues.max { val1, val2 in val1.year < val2.year }!
        let highestYearValue = highestYear.amount / referenceValue
        
        if givingGoal != nil {
            barTwoConstraint?.constant = maxWidth * CGFloat(givingGoalReferenceValue / referenceValue)
            otherConstraint?.constant = maxWidth * CGFloat(highestYearValue.isFinite ? highestYearValue : 0)
        } else {
            barTwoConstraint?.constant = maxWidth * CGFloat(highestYearValue.isFinite ? highestYearValue : 0)
            otherConstraint?.constant = 0

        }
        
        yearBarTwoLabel.text = highestYear.year.string
        
        [yearBarTwo.amountLabel, yearBarTwoOutsideValueLabel].forEach({ label in
            label.text = highestYear.amount.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
        })
        
        let barTwoWidth = barTwoConstraint!.constant-30
        let labelTwoWidth = yearBarTwo.amountLabel.frame.width
                
        if givingGoal == nil {
            if barTwoWidth <= labelTwoWidth {
                yearBarTwo.amountLabel.isHidden = true
                if highestYearValue.isFinite {
                    yearBarTwoOutsideValueLabel.isHidden = false
                }
            }
        }
        
        yearBarTwo.bgView.backgroundColor = ColorHelper.GivtLightGreen
        yearBarTwoOutsideValueLabel.textColor = ColorHelper.GivtLightGreen
        
        if givingGoal != nil {
            yearBarTwo.bgView.backgroundColor = ColorHelper.GivtLightLightGreen
            yearBarTwoOutsideValueLabel.textColor = ColorHelper.GivtLightLightGreen
            
            [yearBarTwo.amountLabel, yearBarTwoOutsideValueLabel].forEach({ label in
                label.text = givingGoalReferenceValue.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
            })
            
            [yearBarTwo.amountLabelInside, yearBarTwo.amountLabelOutside].forEach({ label in
                label.text = highestYear.amount.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
            })

            let labelForWidthDetermination = UILabel()
            labelForWidthDetermination.font = UIFont(name: "Avenir-Black", size: 12)
            labelForWidthDetermination.text = highestYear.amount.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
            labelForWidthDetermination.sizeToFit()
            
            let currentAmountViewConstant = maxWidth * CGFloat(highestYearValue.isFinite ? highestYearValue : 0)
            let currentAmountInsideLabel = labelForWidthDetermination.frame.width
            
           
            if currentAmountInsideLabel > currentAmountViewConstant {
                yearBarTwo.amountLabelInside.isHidden = true
                yearBarTwo.amountLabelOutside.isHidden = false
            } else {
                yearBarTwo.amountLabelInside.isHidden = false
                yearBarTwo.amountLabelOutside.isHidden = true
                yearBarTwo.amountLabel.leadingAnchor.constraint(equalTo: yearBarTwo.givenAmountView.trailingAnchor, constant: 0).isActive = true
            }
        }
        
        if yearsWithValues.filter({ $0.amount == 0.0 }).count == 2 {
            if yearBarOne != nil {
                yearBarOneStackItem.removeFromSuperview()
            }
        } else if yearsWithValues.filter({ $0.amount == 0.0 }).count == 1 {
            let emptyYear = yearsWithValues.first { item in item.amount == 0.0 }
            if emptyYear!.year == currentYear - 1 {
                if yearBarOne != nil {
                    yearBarOneStackItem.removeFromSuperview()
                }
            }
        }
    }
    
    func getFromDateForYearlyOverview() -> String {
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
