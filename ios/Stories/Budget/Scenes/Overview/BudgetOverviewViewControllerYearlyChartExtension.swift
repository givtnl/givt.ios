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
class YearUIView: UIView {
    var year: Int?
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
        
        if yearBarOne != nil {
            let lowestYear = yearsWithValues.min(by: { val1, val2 in val1.year < val2.year })!
            let lowestYearValue = lowestYear.amount / referenceValue
            yearBarOneLabel.text = lowestYear.year.string
            yearOneTapView.year = lowestYear.year
            yearBarOne.givenViewWidthConstraint.constant = maxWidth * CGFloat(lowestYearValue.isFinite ? lowestYearValue : 0)
            yearBarOne.givenView.backgroundColor = ColorHelper.SoftenedGivtPurple
            yearBarOne.alternateLabel.textColor = ColorHelper.SoftenedGivtPurple
            yearBarOne.givenLabel.text = lowestYear.amount.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
            yearBarOne.alternateLabel.text = lowestYear.amount.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
            yearBarOne.hideGivingGoal()
            if #available(iOS 11.0, *) {
                yearBarOne.givenView.layer.cornerRadius = 7
                yearBarOne.givenView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            }
            
            let labelForWidth = UILabel()
            labelForWidth.font = UIFont(name: "Avenir-Black", size: 12)
            labelForWidth.text = yearBarOne.givenLabel.text
            labelForWidth.sizeToFit()
            
            if labelForWidth.frame.width > yearBarOne.givenViewWidthConstraint.constant {
                yearBarOne.givenLabel.isHidden = true
                yearBarOne.alternateLabel.isHidden = false
            } else {
                yearBarOne.givenLabel.isHidden = false
                yearBarOne.alternateLabel.isHidden = true
            }
            yearOneTapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openYearlyOverview)))
        }
        
        if yearBarTwo != nil {
            let highestYear = yearsWithValues.max { val1, val2 in val1.year < val2.year }!
            let highestYearValue = highestYear.amount / referenceValue
            yearBarTwoLabel.text = highestYear.year.string
            yearTwoTapView.year = highestYear.year
            yearBarTwo.givenViewWidthConstraint.constant = maxWidth * CGFloat(highestYearValue.isFinite ? highestYearValue : 0)
            yearBarTwo.givenView.backgroundColor = ColorHelper.GivtLightGreen
            yearBarTwo.alternateLabel.textColor = ColorHelper.GivtLightGreen
            yearBarTwo.givenLabel.text = highestYear.amount.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
            yearBarTwo.alternateLabel.text = highestYear.amount.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
            yearBarTwo.hideGivingGoal()
            if #available(iOS 11.0, *) {
                yearBarTwo.givenView.layer.cornerRadius = 7
                yearBarTwo.givenView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            }
            
            let labelForWidth = UILabel()
            labelForWidth.font = UIFont(name: "Avenir-Black", size: 12)
            labelForWidth.text = yearBarTwo.givenLabel.text
            labelForWidth.sizeToFit()

            if labelForWidth.frame.width > yearBarTwo.givenViewWidthConstraint.constant {
                yearBarTwo.givenLabel.isHidden = true
                yearBarTwo.alternateLabel.isHidden = false
            } else {
                yearBarTwo.givenLabel.isHidden = false
                yearBarTwo.alternateLabel.isHidden = true
            }
            yearTwoTapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openYearlyOverview)))

            if givingGoal != nil {
                let givingGoalBarWidth = (maxWidth * CGFloat(givingGoalReferenceValue / referenceValue)) - yearBarTwo.givenViewWidthConstraint.constant
                
                if givingGoalBarWidth > 0 {
                    yearBarTwo.givenView.layer.cornerRadius = 0
                    yearBarTwo.showGivingGoal()
                    yearBarTwo.givingGoalWidthConstraint.constant = givingGoalBarWidth
                    yearBarTwo.givingGoalLabel.text = givingGoalReferenceValue.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                    yearBarTwo.givingGoalView.backgroundColor = ColorHelper.GivtLightLightGreen
                    
                    if #available(iOS 11.0, *) {
                        yearBarTwo.givingGoalView.layer.cornerRadius = 7
                        yearBarTwo.givingGoalView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                    }
                    
                    if yearBarTwo.givingGoalLabel.frame.width > yearBarTwo.givingGoalWidthConstraint.constant {
                        yearBarTwo.givingGoalLabel.isHidden = true
                    } else {
                        yearBarTwo.givingGoalLabel.isHidden = false
                    }
                }
            }
        }
        
        if yearsWithValues.filter({ $0.amount == 0.0 }).count == 2 {
            if yearBarOne != nil {
                yearBarOneStackItem.removeFromSuperview()
                yearOneTapView.removeFromSuperview()
            }
        } else if yearsWithValues.filter({ $0.amount == 0.0 }).count == 1 {
            let emptyYear = yearsWithValues.first { item in item.amount == 0.0 }
            if emptyYear!.year == currentYear - 1 {
                if yearBarOne != nil {
                    yearBarOneStackItem.removeFromSuperview()
                    yearOneTapView.removeFromSuperview()
                }
            }
        }
        

    }
    @objc func openYearlyOverview(_ sender: UITapGestureRecognizer) {
        let year = (sender.view as! YearUIView).year!
        
        if year == Date().getYear() {
            trackEvent("CLICKED", properties: ["BUTTON_NAME": "CurrentYearBarClicked"])
        } else {
            trackEvent("CLICKED", properties: ["BUTTON_NAME": "PreviousYearBarClicked"])
        }
        
        if !AppServices.shared.isServerReachable {
            try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
        } else {
            NavigationManager.shared.executeWithLogin(context: self) {
                try! Mediater.shared.send(request: OpenYearlyOverviewRoute(year: year), withContext: self)
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
