//
//  BudgetGivingGoalViewControllerExtension.swift
//  ios
//
//  Created by Mike Pattyn on 04/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension BudgetGivingGoalViewController {
    private func setupTerms() {
        navBar.title = "Streefbedrag instelleuh"
        infoLabel.attributedText = createInfoText(bold: "Stel jezelf een doel", normal: "Geef bewust. Weeg elke maand af of je geefgedrag past bij je persoonlijke ambities.")
        amountTitelLabel.text = "Mijn streefbedrag"
        periodTitelLabel.text = "Periode"
    }
    private func setupUI() {
        periodViewLabelDown.layer.addBorder(edge: .left, color: ColorHelper.UITextFieldBorderColor, thickness: 0.5)
        periodView.borderColor = ColorHelper.UITextFieldBorderColor
        periodView.borderWidth = 0.5
        
        amountViewLabelCurrency.layer.addBorder(edge: .right, color: ColorHelper.UITextFieldBorderColor, thickness: 0.5)
        amountView.borderColor = ColorHelper.UITextFieldBorderColor
        amountView.borderWidth = 0.5
    }
    private func createInfoText(bold: String, normal: String) -> NSMutableAttributedString {
        return NSMutableAttributedString()
            .bold(bold.localized + "\n", font: UIFont(name: "Avenir-Black", size: 15)!)
            .normal(normal.localized, font: UIFont(name: "Avenir-Light", size: 15)!)
        
    }
}
