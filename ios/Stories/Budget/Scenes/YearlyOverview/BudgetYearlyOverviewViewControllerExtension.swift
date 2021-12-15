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
        let fromDate = year.getUTCDateForYear(type: .start)
        let tillDate = year.getUTCDateForYear(type: .end)
        
        try! Mediater.shared.sendAsync(request: GetMonthlySummaryQuery(fromDate: fromDate, tillDate: tillDate, groupType: 2, orderType: 3)) { givtModels in
            self.givtModels = givtModels
            try! Mediater.shared.sendAsync(request: GetMonthlySummaryQuery(
                fromDate: (self.year-1).getUTCDateForYear(type: .start),
                tillDate: (self.year-1).getUTCDateForYear(type: .end),
                groupType: 2, orderType: 3)) { givtModelsPreviousYear in
                self.previousYearGivtModels = givtModelsPreviousYear
            }
            
            DispatchQueue.main.async {
                let totalGivt = givtModels.map { $0.Value }.reduce(0, +)
                self.amountGivt.text = CurrencyHelper.shared.getLocalFormat(value: totalGivt.toFloat, decimals: true)
                self.loadGivtModels(givtModels)

            }
            

            try! Mediater.shared.sendAsync(request: GetExternalMonthlySummaryQuery(fromDate: fromDate , tillDate: tillDate, groupType: 2, orderType: 3)) { notGivtModels in
                try! Mediater.shared.sendAsync(request: GetExternalMonthlySummaryQuery(
                    fromDate: (self.year-1).getUTCDateForYear(type: .start),
                    tillDate: (self.year-1).getUTCDateForYear(type: .end),
                    groupType: 2, orderType: 3)) { previousNotGivtModels in
                    self.previousYearNotGivtModels = previousNotGivtModels
                }
                self.notGivtModels = notGivtModels
                DispatchQueue.main.async {
                    let totalNotGivt = notGivtModels.map { $0.Value }.reduce(0, +)
                    let totalGivt = givtModels.map { $0.Value }.reduce(0, +)
                    let total = totalNotGivt + totalGivt
                    self.amountNotGivt.text = CurrencyHelper.shared.getLocalFormat(value: totalNotGivt.toFloat, decimals: true)
                    self.amountTotal.text = CurrencyHelper.shared.getLocalFormat(value: total.toFloat, decimals: true)
                    let givtAmountTax = givtModels.filter { $0.TaxDeductable != nil && $0.TaxDeductable! }.map { $0.Value }.reduce(0, +)
                    let notGivtAmountTax = notGivtModels.filter { $0.TaxDeductable != nil && $0.TaxDeductable! }.map { $0.Value }.reduce(0, +)
                    let totalTax = givtAmountTax + notGivtAmountTax
                    self.amountTax.text = CurrencyHelper.shared.getLocalFormat(value: totalTax.toFloat, decimals: true)
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
}
