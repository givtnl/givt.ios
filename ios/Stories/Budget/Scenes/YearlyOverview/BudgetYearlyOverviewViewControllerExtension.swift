//
//  BudgetYearlyOverviewViewControllerExtension.swift
//  ios
//
//  Created by Mike Pattyn on 04/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import SVProgressHUD
import UIKit

extension MonthlySummaryKey {
    func toDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = self.Year
        dateComponents.month = self.Month
        return Calendar.current.date(from: dateComponents)!
    }
}


extension BudgetYearlyOverviewViewController {
    func setupTerms() {
        navItem.title = year.string
        labelGivt.text = "BudgetYearlyOverviewGivenThroughGivt".localized
        labelNotGivt.text = "BudgetYearlyOverviewGivenThroughNotGivt".localized
        labelTotal.text = "BudgetYearlyOverviewGivenTotal".localized
        labelTax.text = "BudgetYearlyOverviewGivenTotalTax".localized
        downloadButton.setTitle("BudgetYearlyOverviewDownloadButton".localized, for: .normal)
        monthlyBarsHeader.label.text = "BudgetSummaryMonth".localized
        givtLegendLabel.text = "BudgetYearlyOverviewDetailThroughGivt".localized
        notGivtLegendLabel.text = "BudgetYearlyOverviewDetailNotThroughGivt".localized
        organisationGivtCardHeader.label.text = "BudgetYearlyOverviewPerOrganisation".localized
        organisationGivt.text = "BudgetSummaryGivt".localized
        organisationNotGivt.text = "BudgetSummaryNotGivt".localized
    }

    func reloadData() {
        let fromDate = getUTCDateForYear(year: year, type: .start)
        let tillDate = getUTCDateForYear(year: year, type: .end)
        
        try! Mediater.shared.sendAsync(request: GetMonthlySummaryQuery(fromDate: fromDate, tillDate: tillDate, groupType: 2, orderType: 3)) { givtModels in
            self.givtModels = givtModels
            try! Mediater.shared.sendAsync(request: GetMonthlySummaryQuery(fromDate: self.getUTCDateForYear(year: self.year-1, type: .start), tillDate: self.getUTCDateForYear(year: self.year-1, type: .end), groupType: 2, orderType: 3)) { givtModelsPreviousYear in
                self.previousYearGivtModels = givtModelsPreviousYear
            }
            
            DispatchQueue.main.async {
                self.amountGivt.text = givtModels.map { $0.Value }.reduce(0, +).getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                self.loadGivtModels(givtModels)

            }
            

            try! Mediater.shared.sendAsync(request: GetExternalMonthlySummaryQuery(fromDate: fromDate , tillDate: tillDate, groupType: 2, orderType: 3)) { notGivtModels in
                try! Mediater.shared.sendAsync(request: GetExternalMonthlySummaryQuery(fromDate: self.getUTCDateForYear(year: self.year-1, type: .start), tillDate: self.getUTCDateForYear(year: self.year-1, type: .end), groupType: 2, orderType: 3)) { previousNotGivtModels in
                    self.previousYearNotGivtModels = previousNotGivtModels
                }
                self.notGivtModels = notGivtModels
                DispatchQueue.main.async {
                    self.amountNotGivt.text = notGivtModels.map { $0.Value }.reduce(0, +).getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                    self.amountTotal.text = (notGivtModels.map { $0.Value }.reduce(0, +) + givtModels.map { $0.Value }.reduce(0, +)).getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                    let givtAmountTax = givtModels.filter { $0.TaxDeductable != nil && $0.TaxDeductable! }.map { $0.Value }.reduce(0, +)
                    let notGivtAmountTax = notGivtModels.filter { $0.TaxDeductable != nil && $0.TaxDeductable! }.map { $0.Value }.reduce(0, +)
                    self.amountTax.text = (givtAmountTax + notGivtAmountTax).getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                    self.loadNotGivtModels(notGivtModels)
                }
                
                
                try! Mediater.shared.sendAsync(request: GetGivingGoalQuery(), completion: { response in
                    DispatchQueue.main.async {
                        self.determineWhichCardsToShow(
                            givingGoal: response.result,
                            donations: self.previousYearGivtModels + self.previousYearNotGivtModels,
                            currentTotalThisYear: notGivtModels.map { $0.Value }.reduce(0, +) + givtModels.map { $0.Value }.reduce(0, +)
                        )
                        SVProgressHUD.dismiss()
                        self.hideView(self.mainView, false)
                    }
                })
            }
        }
    }
    
    enum DateType {
        case start
        case end
    }
    func getUTCDateForYear(year: Int, type: DateType) -> String {
        var componentsForYearlySummaryComponents = DateComponents()
        componentsForYearlySummaryComponents.day = 1
        componentsForYearlySummaryComponents.month = 1
        componentsForYearlySummaryComponents.year = [DateType.start: year, DateType.end: year+1][type]
        let date = Calendar.current.date(from: componentsForYearlySummaryComponents)!
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: date)
    }
}
