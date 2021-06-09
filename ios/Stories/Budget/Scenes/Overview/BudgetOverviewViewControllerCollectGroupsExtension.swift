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
        
        stackViewGivt.arrangedSubviews.forEach { arrangedSubview in
            arrangedSubview.removeFromSuperview()
        }
        
        stackViewGivtHeight.constant = originalStackviewGivtHeight!
        
        stackViewNotGivt.arrangedSubviews.forEach { arrangedSubview in
            arrangedSubview.removeFromSuperview()
        }
        
        stackViewNotGivtHeight.constant = originalStackviewNotGivtHeight!
        
        var count = 0
        
        if let currentMonthSummaryCollectGroups = collectGroupsForCurrentMonth {
            if currentMonthSummaryCollectGroups.count >= 1 {
                currentMonthSummaryCollectGroups.forEach { model in
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
                addEmptyLine(stackView: stackViewGivt, stackViewHeight: stackViewGivtHeight, givtDonation: true)
            }
        } else {
            addEmptyLine(stackView: stackViewGivt, stackViewHeight: stackViewGivtHeight, givtDonation: true)
        }
        
        
 
        
        count = 0
        
        if let notGivtModels = notGivtModelsForCurrentMonth {
            if notGivtModels.count >= 1 {
                notGivtModels.forEach { model in
                    if count < 2 {
                        if fromMonth.getYear() == Date().getYear && fromMonth.getMonth() == Date().getMonth() {
                            let notGivtRow: LineWithIcon = LineWithIcon(
                                id: model.id,
                                description: model.description,
                                amount: model.amount
                            )
                            
                            let notGivtTapGesture = UITapGestureRecognizer(target: self, action: #selector(noGivtsAction))
                            notGivtRow.addGestureRecognizer(notGivtTapGesture)
                            stackViewNotGivt.addArrangedSubview(notGivtRow)
                            stackViewNotGivtHeight.constant += 22
                        } else {
                            let view = MonthlyCardViewLine()
                            view.collectGroupLabel.text = model.description
                            view.amountLabel.text = model.amount.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                            stackViewNotGivt.addArrangedSubview(view)
                            stackViewNotGivtHeight.constant += 22
                        }
                        count+=1
                    }
                }
            } else {
                addEmptyLine(stackView: stackViewNotGivt, stackViewHeight: stackViewNotGivtHeight)
            }
        } else {
            addEmptyLine(stackView: stackViewNotGivt, stackViewHeight: stackViewNotGivtHeight)
        }
    }
    
    private func addEmptyLine(stackView: UIStackView, stackViewHeight: NSLayoutConstraint, givtDonation: Bool = false) {
        let view = MonthlyCardViewLine()
        view.collectGroupLabel.text = givtDonation ? "BudgetSummaryNoGifts".localized : "BudgetSummaryNoGiftsExternal".localized
        view.amountLabel.text = String.empty
        stackView.addArrangedSubview(view)
        stackViewHeight.constant += 22
    }
}
