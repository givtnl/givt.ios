//
//  BudgetListViewControllerExtension.swift
//  ios
//
//  Created by Mike Pattyn on 29/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension BudgetListViewController {
    func setupTerms() {
        headerLabel.text = getFullMonthStringFromDateValue(value: monthDate!).capitalized
        labelGivt.text = "BudgetSummaryGivt".localized
        labelNotGivt.text = "BudgetSummaryNotGivt".localized
        buttonExternal.setTitle("BudgetExternalGiftsListAddEditButton".localized, for: .normal)
    }
    func setupHeader() {
        if #available(iOS 11.0, *) {
            headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            headerView.layer.cornerRadius = 6
            headerView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            headerView.layer.borderWidth = 1
            headerView.layer.masksToBounds = true
        } else {
            // Fallback on earlier versions
            headerView.roundCorners(corners: [.topLeft, .topRight], radius: 6)
        }
    }
    func loadDonations() {
        
        stackViewGivt.arrangedSubviews.forEach { arrangedSubview in
            arrangedSubview.removeFromSuperview()
        }
        
        stackViewGivtHeight.constant = 0
        
        stackViewNotGivt.arrangedSubviews.forEach { arrangedSubview in
            arrangedSubview.removeFromSuperview()
        }
        
        stackViewNotGivtHeight.constant = 0
        
        if collectGroupsForCurrentMonth != nil && collectGroupsForCurrentMonth!.count >= 1 {
            collectGroupsForCurrentMonth!.forEach { model in
                let view = MonthlyCardViewLine()
                view.collectGroupLabel.text = model.Key
                view.amountLabel.text = CurrencyHelper.shared.getLocalFormat(value: model.Value.toFloat, decimals: true)
                stackViewGivt.addArrangedSubview(view)
                stackViewGivtHeight.constant += 22
            }
        } else {
            addEmptyLine(stackView: stackViewGivt, stackViewHeight: stackViewGivtHeight)
        }
        
        if notGivtModelsForCurrentMonth != nil && notGivtModelsForCurrentMonth!.count >= 1 {
            notGivtModelsForCurrentMonth!.forEach { model in
                let view = MonthlyCardViewLine()
                view.collectGroupLabel.text = model.description
                view.amountLabel.text = CurrencyHelper.shared.getLocalFormat(value: model.amount.toFloat, decimals: true)
                stackViewNotGivt.addArrangedSubview(view)
                stackViewNotGivtHeight.constant += 22
            }
        } else {
            addEmptyLine(stackView: stackViewNotGivt, stackViewHeight: stackViewNotGivtHeight)
        }
    }
    private func addEmptyLine(stackView: UIStackView, stackViewHeight: NSLayoutConstraint) {
        let view = MonthlyCardViewLine()
        view.collectGroupLabel.text = "BudgetSummaryNoGifts".localized
        view.amountLabel.text = String.empty
        stackView.addArrangedSubview(view)
        stackViewHeight.constant += 22
    }
    private func getFullMonthStringFromDateValue(value: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: value).replacingOccurrences(of: ".", with: String.empty)
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
        dateComponents.month = currentMonth
        dateComponents.day = getDaysInMonth(month: Int(currentMonth), year: Int(currentYear))
        let date = calendar.date(from: dateComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
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
}
