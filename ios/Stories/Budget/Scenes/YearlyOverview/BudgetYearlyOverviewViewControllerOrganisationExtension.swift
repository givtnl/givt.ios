//
//  BudgetYearlyOverviewViewControllerOrganisationExtension.swift
//  ios
//
//  Created by Mike Pattyn on 05/07/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
extension MonthlyCardViewLine {
    static func Empty(description: String) -> MonthlyCardViewLine {
        let line = MonthlyCardViewLine()
        line.collectGroupLabel.text = description
        line.amountLabel.text = String.empty
        return line
    }
}
extension BudgetYearlyOverviewViewController {
    
    func loadGivtModels(_ models: [MonthlySummaryDetailModel]) {
        guard models.count > 0 else {
            organisationGivtStackView.addArrangedSubview(MonthlyCardViewLine.Empty(description: "BudgetSummaryNoGiftsYearlyOverview".localized))
            organisationGivtStackViewHeight.constant += 22
            return
        }
        models.forEach({ givtModel in
            let line = MonthlyCardViewLine()
            line.amountLabel.text = givtModel.Value.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
            line.collectGroupLabel.text = givtModel.Key
            organisationGivtStackView.addArrangedSubview(line)
            organisationGivtStackViewHeight.constant += 22
        })
    }
    func loadNotGivtModels(_ models: [MonthlySummaryDetailModel]) {
        guard models.count > 0 else {
            organisationNotGivtStackView.addArrangedSubview(MonthlyCardViewLine.Empty(description: "BudgetSummaryNoGiftsYearlyOverview".localized))
            organisationNotGivtStackViewHeight.constant += 22
            return
        }
        models.forEach({ givtModel in
            let line = MonthlyCardViewLine()
            line.amountLabel.text = givtModel.Value.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
            line.collectGroupLabel.text = givtModel.Key
            organisationNotGivtStackView.addArrangedSubview(line)
            organisationNotGivtStackViewHeight.constant += 22
        })
    }
}
