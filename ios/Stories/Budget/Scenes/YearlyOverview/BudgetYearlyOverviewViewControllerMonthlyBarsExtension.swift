//
//  BudgetYearlyOverviewViewControllerMonthlyBarsExtension.swift
//  ios
//
//  Created by Mike Pattyn on 03/07/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension BudgetYearlyOverviewViewController {
    typealias GetBarsCompletionHandler = (_ response: [YearlyOverviewMonthlyBarViewModel]) -> Void
    
    func getDataForMonthBars(completionHandler: @escaping GetBarsCompletionHandler) {
        let numberOfMonthsToFetch: Int = year == Date().getYear() ? Date().getMonth() : 12
        var retArray: [MonthlySummaryKey: YearlyOverviewMonthlyBarViewModel] = [:]
        let fromDate = getStartDateForYear(year: year)
        let tillDate = getEndDateForYear(year: year)
                
        for int in 1...numberOfMonthsToFetch {
            let keyValues = MonthlySummaryKey(Year: year, Month: int)
            retArray[keyValues] = YearlyOverviewMonthlyBarViewModel()
            retArray[keyValues]!.date = keyValues.toDate()
        }
        
        try! Mediater.shared.sendAsync(request: GetMonthlySummaryQuery(fromDate: fromDate, tillDate: tillDate, groupType: 0, orderType: 3)) { givtModels in
            
            givtModels.forEach { model in
                let keyValues = MonthlySummaryKey(Year: Int(model.Key.split(separator: "-")[0])!, Month: Int(model.Key.split(separator: "-")[1])!)
                retArray[keyValues]?.givtAmount = model.Value
            }
            
            try! Mediater.shared.sendAsync(request: GetExternalMonthlySummaryQuery(fromDate: fromDate, tillDate: tillDate, groupType: 0, orderType: 3)) { notGivtModels in
                
                notGivtModels.forEach { model in
                    let keyValues = MonthlySummaryKey(Year: Int(model.Key.split(separator: "-")[0])!, Month: Int(model.Key.split(separator: "-")[1])!)
                    retArray[keyValues]?.notGivtAmount = model.Value
                }
                completionHandler(retArray.map { $0.value })
            }
        }
    }
    
    func loadMonthBars(monthBars: [YearlyOverviewMonthlyBarViewModel]) {
        for int in 0...monthBars.count - 1 {
            let monthlyBar = YearlyOverviewMonthlyBar()
            monthlyBar.tag = int
            monthlyBarsStackView.addArrangedSubview(monthlyBar)
            monthlyBarsStackViewHeight.constant += 25
            monthlyBar.monthlyBarViewModel = monthBars[int]
        }
        
    }
}
