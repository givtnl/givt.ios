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
        stackViewGivt.arrangedSubviews.forEach { arrangedSubview in
            arrangedSubview.removeFromSuperview()
        }
        
        stackViewGivtHeight.constant = originalStackviewGivtHeight!
        
        stackViewNotGivt.arrangedSubviews.forEach { arrangedSubview in
            arrangedSubview.removeFromSuperview()
        }
        
        stackViewNotGivtHeight.constant = originalStackviewNotGivtHeight!
        
        if collectGroupsForCurrentMonth.count >= 1 {
            var firstCollectGroups: [MonthlySummaryDetailModel] = [MonthlySummaryDetailModel]()
            if collectGroupsForCurrentMonth.count == 1 {
                firstCollectGroups.append(collectGroupsForCurrentMonth[0])
            } else {
                firstCollectGroups = [collectGroupsForCurrentMonth[0], collectGroupsForCurrentMonth[1]]
            }
            
            firstCollectGroups.forEach { model in
                let view = MonthlyCardViewLine()
                view.collectGroupLabel.text = model.Key
                view.amountLabel.text = model.Value.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                stackViewGivt.addArrangedSubview(view)
                stackViewGivtHeight.constant += 22
            }
        }
        
        let notGivtModels: [ExternalDonationModel] = try! Mediater.shared.send(request: GetAllExternalDonationsQuery()).result
        
        notGivtModels.forEach { model in
            let notGivtTapGesture = UITapGestureRecognizer(target: self, action: #selector(noGivtsAction))

            let notGivtRow: LineWithIcon = LineWithIcon(
                id: model.id,
                description: model.description,
                amount: model.amount
            )
            notGivtRow.addGestureRecognizer(notGivtTapGesture)
            stackViewNotGivt.addArrangedSubview(notGivtRow)
            stackViewNotGivtHeight.constant += 22
            
        }
    }
}
