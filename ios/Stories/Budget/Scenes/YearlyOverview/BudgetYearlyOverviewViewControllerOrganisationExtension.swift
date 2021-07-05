//
//  BudgetYearlyOverviewViewControllerOrganisationExtension.swift
//  ios
//
//  Created by Mike Pattyn on 05/07/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

extension BudgetYearlyOverviewViewController {
    func loadGivtModels(_ models: [MonthlySummaryDetailModel]) {
        models.forEach({ givtModel in
            let line = MonthlyCardViewLine()
            line.amountLabel.text = givtModel.Value.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
            line.collectGroupLabel.text = givtModel.Key
            organisationGivtStackView.addArrangedSubview(line)
            organisationGivtStackViewHeight.constant += 22
        })
    }
    func loadNotGivtModels(_ models: [MonthlySummaryDetailModel]) {
        models.forEach({ givtModel in
            let line = MonthlyCardViewLine()
            line.amountLabel.text = givtModel.Value.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
            line.collectGroupLabel.text = givtModel.Key
            organisationNotGivtStackView.addArrangedSubview(line)
            organisationNotGivtStackViewHeight.constant += 22
        })
    }
}
