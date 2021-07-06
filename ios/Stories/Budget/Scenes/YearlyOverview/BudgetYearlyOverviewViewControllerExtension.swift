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
        organisationGivtCardHeader.label.text = "Per organisation".localized
        organisationGivt.text = "BudgetYearlyOverviewDetailThroughGivt".localized
        organisationNotGivt.text = "BudgetYearlyOverviewDetailNotThroughGivt".localized
    }

    func reloadData() {
        let fromDate = getStartDateForYear(year: year)
        let tillDate = getEndDateForYear(year: year)
        
        try! Mediater.shared.sendAsync(request: GetMonthlySummaryQuery(fromDate: fromDate, tillDate: tillDate, groupType: 2, orderType: 3)) { givtModels in
            self.givtModels = givtModels
            try! Mediater.shared.sendAsync(request: GetMonthlySummaryQuery(fromDate: self.getStartDateForYear(year: self.year-1), tillDate: self.getEndDateForYear(year: self.year-1), groupType: 2, orderType: 3)) { givtModelsPreviousYear in
                self.previousYearGivtModels = givtModelsPreviousYear
            }
            
            DispatchQueue.main.async {
                self.amountGivt.text = givtModels.map { $0.Value }.reduce(0, +).getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                self.loadGivtModels(givtModels)

            }
            

            try! Mediater.shared.sendAsync(request: GetExternalMonthlySummaryQuery(fromDate: fromDate , tillDate: tillDate, groupType: 2, orderType: 3)) { notGivtModels in
                try! Mediater.shared.sendAsync(request: GetExternalMonthlySummaryQuery(fromDate: self.getStartDateForYear(year: self.year-1), tillDate: self.getEndDateForYear(year: self.year-1), groupType: 2, orderType: 3)) { previousNotGivtModels in
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
    func getStartDateForYear(year: Int) -> String {
        var componentsForYearlySummaryComponents = DateComponents()
        componentsForYearlySummaryComponents.day = 1
        componentsForYearlySummaryComponents.month = 1
        componentsForYearlySummaryComponents.year = year
        let date = Calendar.current.date(from: componentsForYearlySummaryComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    func getEndDateForYear(year: Int) -> String {
        var componentsForYearlySummaryComponents = DateComponents()
        componentsForYearlySummaryComponents.day = 1
        componentsForYearlySummaryComponents.month = 1
        componentsForYearlySummaryComponents.year = year + 1
        let date = Calendar.current.date(from: componentsForYearlySummaryComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}
