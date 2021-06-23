//
//  BudgetYearlyOverviewViewControllerStatisticsExtension.swift
//  ios
//
//  Created by Mike Pattyn on 23/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension BudgetYearlyOverviewViewController {
    //-- MARK: Setup functions for different cards
    func setupTotalGivenPerYearCard() {
        totalGivenPerYearAmountLabel.text = "€ 450,00"
        totalGivenPerYearAmountDescription.text = "Gegeven in 2021"
    }
    func setupGivingGoalPerYearCard() {
        givingGoalPerYearAmountLabel.text = "€ 800,00"
        givingGoalPerYearDescriptionLabel.text = "Streefbedrag per jaar"
        givingGoalPerYearEditGivingGoalLabel.attributedText = "BudgetSummaryGivingGoalEdit".localized.underlined
    }
    func setupGivingGoalPerYearRemainingCard() {
        givingGoalPerYearRemainingAmountLabel.text = "€ 350,00"
        givingGoalPerYearRemainingDescriptionLabel.text = "Resterend streefbedrag"
    }
    func setupGivingGoalSmallSetupCard() {
        givingGoalSetupSmallLabel.attributedText = createAttributeText(bold: "BudgetSummarySetGoalBold", normal: "BudgetSummarySetGoal")
    }
    
    func setupGivingGoalBigSetupCard() {
        givingGoalBigSetupLabel.attributedText = createAttributeText(bold: "BudgetSummarySetGoalBold", normal: "BudgetSummarySetGoal")
    }
    func setupGivingGoalAmountBigCard() {
        givingGoalBigAmountLabel.text = "€ 800"
        givingGoalBigDescriptionLabel.text = "Streefbedrag per jaar"
    }
    func setupGivingGoalPercentagePreviousYearCard() {
        givingGoalPercentagePreviousYearAmountLabel.text = "58%"
        givingGoalPercentagePreviousYearDescriptionLabel.text = "Ten opzichte van totaal 2020"
    }
    
    //-- MARK: Methods
    func showGivingGoalWithoutPreviousYearCards(_ shouldHide: Bool = false) {
        givingGoalPerYearStackItem.isHidden = shouldHide
        givingGoalPerYearRemainingStackItem.isHidden = shouldHide
    }
    
    func showNoGivingGoalWithPreviousYearCards(_ shouldHide: Bool = false) {
        givingGoalSmallSetupStackItem.isHidden = shouldHide
        givingGoalPercentagePreviousYearStackItem.isHidden = shouldHide
    }
    
    func showGivingGoalBigSetupCard(_ shouldHide: Bool = false) {
        givingGoalBigSetupStackItem.isHidden = shouldHide
    }
    func showGivingGoalPerYearBigCard(_ shouldHide: Bool = false) {
        givingGoalPerYearBigStackItem.isHidden = shouldHide
    }
    
    func hideStatisticsStackItems() {
        givingGoalPerYearStackItem.isHidden = true
        givingGoalPerYearRemainingStackItem.isHidden = true
        givingGoalSmallSetupStackItem.isHidden = true
        givingGoalPercentagePreviousYearStackItem.isHidden = true
        givingGoalBigSetupStackItem.isHidden = true
        givingGoalPerYearBigStackItem.isHidden = true
    }
    
    //-- MARK: Usefull functions
    func createAttributeText(bold: String, normal: String) -> NSMutableAttributedString {
        return NSMutableAttributedString()
            .bold(bold.localized + "\n", font: UIFont(name: "Avenir-Black", size: 12)!)
            .normal(normal.localized, font: UIFont(name: "Avenir-Medium", size: 12)!)
    }
}
