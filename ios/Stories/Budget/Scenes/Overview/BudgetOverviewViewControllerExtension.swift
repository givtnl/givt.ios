//
//  BudgetViewControllerExtension.swift
//  ios
//
//  Created by Mike Pattyn on 23/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Charts
import Foundation
import UIKit


//MARK: Public extension - used to store public methods
extension BudgetOverviewViewController {
    func setupTerms() {
        monthlySummaryTile.descriptionLabel.text = "BudgetSummaryBalance".localized
        givtNowButton.setTitle("BudgetSummaryGiveNow".localized, for: .normal)
        
        monthlyCardHeader.label.text = getFullMonthStringFromDateValue(value: fromMonth).capitalized
        navigationItem.title = "BudgetMenuView".localized
        chartViewHeader.label.text = "BudgetSummaryMonth".localized
        yearViewHeader.label.text = "BudgetSummaryYear".localized
        labelGivt.text = "BudgetSummaryGivt".localized
        labelNotGivt.text = "BudgetSummaryNotGivt".localized
        buttonSeeMore.setAttributedTitle(NSMutableAttributedString(string: "BudgetSummaryShowAll".localized,
                                      attributes: [NSAttributedString.Key.underlineStyle : true]), for: .normal)
        buttonSeeMore.titleLabel?.tintColor = ColorHelper.GivtPurple //
        
        givingGoalViewEditLabel.attributedText = "BudgetSummaryGivingGoalEdit".localized.underlined
        givingGoalSetupViewLabel.attributedText = createInfoText(bold: "BudgetSummarySetGoalBold", normal: "BudgetSummarySetGoal")
        givingGoalPerMonthInfo.text = "BudgetSummaryGivingGoalMonth".localized
        givingGoalRemainingInfo.text = "BudgetSummaryGivingGoalRest".localized
        givingGoalReachedLabel.text = "BudgetSummaryGivingGoalReached".localized
    }
    
    @objc func noGivtsAction(_ sender: UITapGestureRecognizer) {
        trackEvent("CLICKED", properties: ["BUTTON_NAME": "EditExternalDonation"])

        let view = sender.view as! LineWithIcon
        NavigationManager.shared.executeWithLogin(context: self) {
            try? Mediater.shared.send(request: OpenExternalGivtsRoute(id: view.id!, externalDonations: self.notGivtModelsForCurrentMonth), withContext: self)
        }
    }
    
    func getFromDateForCurrentMonth() -> String {
        let calendar = Calendar.current
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = currentMonth
        dateComponents.day = 1
        let date = calendar.date(from: dateComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    func getTillDateForCurrentMonth() -> String {
        let calendar = Calendar.current
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = currentMonth+1
        dateComponents.day = 1
        let date = calendar.date(from: dateComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    func getMonthStringFromDateValue(value: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: value).replacingOccurrences(of: ".", with: String.empty)
    }
    func getPreviousMonthDate(fromDate: Date) -> Date {
       var dateComponents = DateComponents()
       dateComponents.month = -1
       return Calendar.current.date(byAdding: dateComponents, to: fromDate)!
    }
    func makeFromDateString(year: Int, month: Int, day: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: year, month: month, day: day)
        let tilDate = calendar.date(from: components)!
        var dateComponents = DateComponents()
        dateComponents.month = -11
        let fromDate = Calendar.current.date(byAdding: dateComponents, to: tilDate)
        return dateFormatter.string(from: fromDate!)
    }
    func makeTillDateString(year: Int, month: Int, day: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: year, month: month, day: day)
        return dateFormatter.string(from: calendar.date(from: components)!)
    }
    func getDaysInMonth(month: Int, year: Int) -> Int {
        let calendar = Calendar.current
        var startComps = DateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year
        var endComps = DateComponents()
        endComps.day = 1
        endComps.month = month == 12 ? 1 : month + 1
        endComps.year = month == 12 ? year + 1 : year
        let startDate = calendar.date(from: startComps)!
        let endDate = calendar.date(from:endComps)!
        let diff = calendar.dateComponents([Calendar.Component.day], from: startDate, to: endDate)
        return diff.day!
    }
    func getFullMonthStringFromDateValue(value: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: value).replacingOccurrences(of: ".", with: String.empty)
    }
}
