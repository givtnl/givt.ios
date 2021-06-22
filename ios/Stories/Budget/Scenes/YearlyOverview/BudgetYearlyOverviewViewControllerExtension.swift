//
//  BudgetYearlyOverviewViewControllerExtension.swift
//  ios
//
//  Created by Mike Pattyn on 04/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

extension BudgetYearlyOverviewViewController {
    func setupTerms() {
        navItem.title = year.string
        labelGivt.text = "BudgetYearlyOverviewGivenThroughGivt".localized
        labelNotGivt.text = "BudgetYearlyOverviewGivenThroughNotGivt".localized
        labelTotal.text = "BudgetYearlyOverviewGivenTotal".localized
        labelTax.text = "BudgetYearlyOverviewGivenTotalTax".localized
        downloadButton.setTitle("BudgetYearlyOverviewDownloadButton".localized, for: .normal)
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