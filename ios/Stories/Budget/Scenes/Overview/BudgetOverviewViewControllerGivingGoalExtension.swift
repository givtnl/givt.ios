//
//  BudgetOverviewViewControllerGivingGoalExtension.swift
//  ios
//
//  Created by Mike Pattyn on 04/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension BudgetOverviewViewController {
    func roundCorners(view: UIView) {
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            view.layer.cornerRadius = 6
            view.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            view.layer.borderWidth = 1
            view.layer.masksToBounds = true
        } else {
            // Fallback on earlier versions
            view.roundCorners(corners: [.allCorners], radius: 6)
        }
    }
    func createInfoText(bold: String, normal: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString()
            .bold(bold.localized + "\n", font: UIFont(name: "Avenir-Black", size: 12)!)
            .normal(normal.localized, font: UIFont(name: "Avenir-Light", size: 12)!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        paragraphStyle.alignment = .center
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
    @objc func givingGoalEdit(sender: UITapGestureRecognizer) {
        try? Mediater.shared.send(request: OpenGivingGoalRoute(), withContext: self)
    }
    @objc func givingGoalSetup(sender: UITapGestureRecognizer) {
        try? Mediater.shared.send(request: OpenGivingGoalRoute(), withContext: self)
    }
    
    func setupGivingGoalCard() {
        // add onclick to adjust giving goal
        givingGoalViewEditLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.givingGoalEdit)))
        givingGoalSetupStackItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.givingGoalSetup)))
        
        roundCorners(view: givingGoalView)
        roundCorners(view: remainingGivingGoalView)
        roundCorners(view: givingGoalSetupView)
                
        if givingGoal != nil {
            givingGoalSetupStackItem.isHidden = true
            givingGoalStackItem.isHidden = false
            remainingGivingGoalStackItem.isHidden = false
            
            if givingGoal!.periodicity == 1 {
                givingGoalAmount = givingGoal!.amount / 12
                givingGoalPerMonthText.text = givingGoalAmount!.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)

            } else {
                givingGoalAmount = givingGoal!.amount
                givingGoalPerMonthText.text = givingGoalAmount!.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
            }
        } else {
            givingGoalSetupStackItem.isHidden = false
            givingGoalStackItem.isHidden = true
            remainingGivingGoalStackItem.isHidden = true
        }
    }
}
