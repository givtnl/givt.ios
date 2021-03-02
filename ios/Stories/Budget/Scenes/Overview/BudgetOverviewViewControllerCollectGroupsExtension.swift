//
//  BudgetViewControllerCollectGroupsExtension.swift
//  ios
//
//  Created by Mike Pattyn on 01/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

// MARK: VC Extension With CollectGroupsCard functions
extension BudgetOverviewViewController {
    func setupCollectGroupsCard() {
        let collectGroupsForCurrentMonth: [MonthlySummaryDetailModel] = try! Mediater.shared.send(request: GetMonthlySummaryQuery(
                                                                                            fromDate: getFromDateForCurrentMonth(),
                                                                                            tillDate: getTillDateForCurrentMonth(),
                                                                                            groupType: 2,
                                                                                            orderType: 0))

        if collectGroupsForCurrentMonth.count >= 2 {
            let firstTwoCollectGroups = [collectGroupsForCurrentMonth[0], collectGroupsForCurrentMonth[1]]

            firstTwoCollectGroups.forEach { model in
                let view = MonthlyCardViewLine()
                view.collectGroupLabel.text = model.Key
                view.amountLabel.text = "€ \(String(format: "%.2f", model.Value))"
                stackViewGivt.addArrangedSubview(view)
                stackViewGivtHeight.constant += 22
            }
        }
    }
}
