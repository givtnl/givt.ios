//
//  BudgetOverviewViewControllerMonthPickerExtension.swift
//  ios
//
//  Created by Mike Pattyn on 26/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

extension BudgetOverviewViewController {
    func setupMonthPicker() {
        monthSelectorLabel.text = getFullMonthStringFromDateValue(value: fromMonth).capitalized
    }
    
    func updateMonthCard() {
        SVProgressHUD.show()
        try! Mediater.shared.sendAsync(request: GetMonthlySummaryQuery(fromDate: self.getStartDateOfMonth(date: self.fromMonth),tillDate: self.getEndDateOfMonth(date: self.fromMonth), groupType: 2, orderType: 3)) { givtResponse in
            self.collectGroupsForCurrentMonth = givtResponse
            try! Mediater.shared.sendAsync(request: GetAllExternalDonationsQuery(fromDate: self.getStartDateOfMonth(date: self.fromMonth),tillDate: self.getEndDateOfMonth(date: self.fromMonth))) { notGivtResponse in
                self.notGivtModelsForCurrentMonth = notGivtResponse.result.sorted(by: { first, second in
                    first.creationDate > second.creationDate
                })
                DispatchQueue.main.async {
                    self.monthSelectorLabel.text = self.getFullMonthStringFromDateValue(value: self.fromMonth).capitalized
                    self.setupCollectGroupsCard()
                    self.monthlySummaryTile.amountLabel.text = self.getMonthlySum().getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                    self.setupGivingGoalCard(self.getMonthlySum())
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    func getMonthlySum() -> Double {
        let amountValuesGivt: [Double] = collectGroupsForCurrentMonth!.map { $0.Value }
        let amountValuesNotGivt: [Double] = notGivtModelsForCurrentMonth!.map { $0.amount }
        return amountValuesGivt.reduce(0, +) + amountValuesNotGivt.reduce(0, +)
    }
    
    func getPreviousMonth(from: Date) -> Date  {
        var dateComponent = DateComponents()
        dateComponent.month = -1
        return Calendar.current.date(byAdding: dateComponent, to: from)!
    }
    
    func getNextMonth(from: Date) -> Date {
        var dateComponent = DateComponents()
        dateComponent.month = 1
        return Calendar.current.date(byAdding: dateComponent, to: from)!
    }
    
    func getStartDateOfMonth(date: Date) -> String {
        let calendar = Calendar.current
        let currentYear = Calendar.current.component(.year, from: date)
        let currentMonth = Calendar.current.component(.month, from: date)
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = currentMonth
        dateComponents.day = 1
        let date = calendar.date(from: dateComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    func getEndDateOfMonth(date: Date) -> String {
        let calendar = Calendar.current
        let currentYear = Calendar.current.component(.year, from: date)
        let currentMonth = Calendar.current.component(.month, from: date) + 1
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = currentMonth
        dateComponents.day = -1
        let date = calendar.date(from: dateComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}
