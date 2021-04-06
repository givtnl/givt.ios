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
                                                                                            orderType: 3))
        stackViewGivt.arrangedSubviews.forEach { arrangedSubview in
            arrangedSubview.removeFromSuperview()
        }
        
        stackViewGivtHeight.constant = originalStackviewGivtHeight!
        
        stackViewNotGivt.arrangedSubviews.forEach { arrangedSubview in
            arrangedSubview.removeFromSuperview()
        }
        
        stackViewNotGivtHeight.constant = originalStackviewNotGivtHeight!
        
        var count = 0
        
        if collectGroupsForCurrentMonth.count >= 1 {
            collectGroupsForCurrentMonth.forEach { model in
                if count < 2 {
                    let view = MonthlyCardViewLine()
                    view.collectGroupLabel.text = model.Key
                    view.amountLabel.text = model.Value.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                    stackViewGivt.addArrangedSubview(view)
                    stackViewGivtHeight.constant += 22
                    count += 1
                }
            }
        } else {
            addEmptyLine(stackView: stackViewGivt, stackViewHeight: stackViewGivtHeight)
        }
        
        let notGivtModels: [ExternalDonationModel] = try! Mediater.shared.send(request: GetAllExternalDonationsQuery()).result
        
        count = 0
        
        if notGivtModels.count >= 1 {
            notGivtModels.forEach { model in
                if count < 2 {
                    let notGivtTapGesture = UITapGestureRecognizer(target: self, action: #selector(noGivtsAction))

                    let notGivtRow: LineWithIcon = LineWithIcon(
                        id: model.id,
                        description: model.description,
                        amount: model.amount
                    )
                    notGivtRow.addGestureRecognizer(notGivtTapGesture)
                    stackViewNotGivt.addArrangedSubview(notGivtRow)
                    stackViewNotGivtHeight.constant += 22
                    count+=1
                }
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
}
