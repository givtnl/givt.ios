//
//  BudgetViewControllerCollectGroupsExtension.swift
//  ios
//
//  Created by Mike Pattyn on 01/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

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
                view.amountLabel.text = model.Value.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                stackViewGivt.addArrangedSubview(view)
                stackViewGivtHeight.constant += 22
            }
        }
        
        let notGivtModels: [NotGivtModel] = [
            NotGivtModel(guid: UUID().uuidString, name: "Rode kruis", amount: 50.0),
            NotGivtModel(guid: UUID().uuidString, name: "Kom op tegen kanker", amount: 50.0)
        ]
        
        let notGivtTapGesture = UITapGestureRecognizer(target: self, action: #selector(noGivtsAction))
        notGivtModels.forEach { model in
            let notGivtRow: LineWithIcon = LineWithIcon(
                guid: model.GUID,
                name: model.Name,
                amount: model.Amount
            )
            notGivtRow.addGestureRecognizer(notGivtTapGesture)
            stackViewNotGivt.addArrangedSubview(notGivtRow)
            stackViewNotGivtHeight.constant += 22
            
        }
    }
}
