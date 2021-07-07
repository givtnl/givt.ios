//
//  BudgetYearlyOverviewViewControllerOrganisationExtension.swift
//  ios
//
//  Created by Mike Pattyn on 05/07/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension BudgetYearlyOverviewViewController {
    func loadGivtModels(_ models: [MonthlySummaryDetailModel]) {
        guard models.count > 0 else {
            return addEmpty(organisationGivtStackView, organisationGivtStackViewHeight)
        }
        models.forEach({ givtModel in
            addRow(organisationGivtStackView, organisationGivtStackViewHeight, givtModel)
        })
    }
    func loadNotGivtModels(_ models: [MonthlySummaryDetailModel]) {
        guard models.count > 0 else {
            return addEmpty(organisationNotGivtStackView, organisationNotGivtStackViewHeight)
        }
        models.forEach({ notGivtModel in
            addRow(organisationNotGivtStackView, organisationNotGivtStackViewHeight, notGivtModel)
        })
    }
    private func addEmpty(_ stackView: UIStackView, _ stackViewHeight: NSLayoutConstraint) {
        stackView.addArrangedSubview(MonthlyCardViewLine.Empty(description: "BudgetSummaryNoGiftsYearlyOverview".localized))
        stackViewHeight.constant += 22
    }
    private func addRow(_ stackView: UIStackView, _ stackViewHeight: NSLayoutConstraint, _ model: MonthlySummaryDetailModel) {
        stackView.addArrangedSubview(MonthlyCardViewLine(description: model.Key, amount: model.Value))
        stackViewHeight.constant += 22
    }
}
