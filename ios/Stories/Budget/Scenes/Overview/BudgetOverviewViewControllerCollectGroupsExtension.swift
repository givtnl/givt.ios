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
                        view.amountLabel.text = CurrencyHelper.shared.getLocalFormat(value: model.Value.toFloat, decimals: true)
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
                        if fromMonth.getYear() == Date().getYear() && fromMonth.getMonth() == Date().getMonth() {
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
                            view.amountLabel.text = CurrencyHelper.shared.getLocalFormat(value: model.amount.toFloat, decimals: true)
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
        
        
        
        if let givtModels = collectGroupsForCurrentMonth, let notGivtModels = notGivtModelsForCurrentMonth {
            if givtModels.count > 2 || notGivtModels.count > 2 {
                buttonSeeMore.isHidden = false
                buttonControlView.bottomAnchor.constraint(equalTo: buttonSeeMore.bottomAnchor, constant: 25).isActive = true
            } else {
                buttonSeeMore.isHidden = true
                buttonControlView.bottomAnchor.constraint(equalTo: buttonAddExternalDonationView.bottomAnchor, constant: 15).isActive = true
            }
            buttonControlView.setNeedsUpdateConstraints()
            buttonControlView.setNeedsLayout()
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
