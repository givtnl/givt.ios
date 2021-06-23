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
    func setupTotalGivenPerYearCard(_ amount: Double, _ year: Int) {
        totalGivenPerYearAmountLabel.text = amount.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
        totalGivenPerYearAmountDescription.text = "Gegeven in \(String(describing: year))"
    }
    func setupGivingGoalPerYearCard(_ amount: Double) {
        givingGoalPerYearAmountLabel.text = amount.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
        givingGoalPerYearDescriptionLabel.text = "Streefbedrag per jaar"
        givingGoalPerYearEditGivingGoalLabel.attributedText = "BudgetSummaryGivingGoalEdit".localized.underlined
        givingGoalPerYearStackItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openGivingGoalSetup)))
    }
    func setupGivingGoalPerYearRemainingCard(_ amount: Double) {
        givingGoalPerYearRemainingAmountLabel.text = amount.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
        givingGoalPerYearRemainingDescriptionLabel.text = "Resterend streefbedrag"
    }
    func setupGivingGoalSmallSetupCard() {
        givingGoalSmallSetupStackItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openGivingGoalSetup)))
        givingGoalSetupSmallLabel.attributedText = createAttributeText(bold: "BudgetSummarySetGoalBold", normal: "BudgetSummarySetGoal")
    }
    func setupGivingGoalBigSetupCard() {
        givingGoalBigSetupStackItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openGivingGoalSetup)))
        givingGoalBigSetupLabel.attributedText = createAttributeText(bold: "BudgetSummarySetGoalBold", normal: "BudgetSummarySetGoal")
    }
    func setupGivingGoalAmountBigCard(_ amount: Double) {
        givingGoalBigAmountLabel.text = amount.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
        givingGoalBigDescriptionLabel.text = "Streefbedrag per jaar"
    }
    func setupGivingGoalPercentagePreviousYearCard(_ amount: Double, _ thisYear: Bool) {
        givingGoalPercentagePreviousYearAmountLabel.text = amount.toPercentile(showSign: !thisYear)
        let labelText = thisYear ? "Ten opzichte van totaal \(year-1)" : "Tegenover \(year-1)"
        givingGoalPercentagePreviousYearDescriptionLabel.text = labelText
    }
    
    func setupGivingGoalFinishedCard() {
        givingGoalFinishedLabel.text = "BudgetSummaryGivingGoalReached".localized
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
    func showGivingGoalPerYearAndPercentCards(_ shouldHide: Bool = false) {
        givingGoalPerYearStackItem.isHidden = shouldHide
        givingGoalPercentagePreviousYearStackItem.isHidden = shouldHide
    }
    func showGivingGoalFinishedCard(_ shouldHide: Bool = false) {
        givingGoalPerYearStackItem.isHidden = shouldHide
        givingGoalFinishedStackItem.isHidden = shouldHide
    }
    
    func hideStatisticsStackItems() {
        givingGoalPerYearStackItem.isHidden = true
        givingGoalPerYearRemainingStackItem.isHidden = true
        givingGoalSmallSetupStackItem.isHidden = true
        givingGoalPercentagePreviousYearStackItem.isHidden = true
        givingGoalBigSetupStackItem.isHidden = true
        givingGoalPerYearBigStackItem.isHidden = true
        givingGoalFinishedStackItem.isHidden = true
    }
    //-- MARK: Usefull functions
    func createAttributeText(bold: String, normal: String) -> NSMutableAttributedString {
        return NSMutableAttributedString()
            .bold(bold.localized + "\n", font: UIFont(name: "Avenir-Black", size: 12)!)
            .normal(normal.localized, font: UIFont(name: "Avenir-Medium", size: 12)!)
    }
    
    @objc func openGivingGoalSetup() {
        if !AppServices.shared.isServerReachable {
            try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
        } else {
            NavigationManager.shared.executeWithLogin(context: self) {
                try? Mediater.shared.send(request: OpenGivingGoalRoute(), withContext: self)
            }
        }
    }
    func determineWhichCardsToShow(givingGoal: GivingGoal?, donations: [MonthlySummaryDetailModel]?, currentTotalThisYear: Double) {
        hideStatisticsStackItems()
        let weHavePastDonations = donations != nil && donations!.count > 0
        let isCurrentYear = year == Date().getYear()
        let sumOfLastYearsDonations = donations?.map { $0.Value }.reduce(0, +) ?? 0
        var percentage: Double = 0.00
        if isCurrentYear {
            percentage = currentTotalThisYear / sumOfLastYearsDonations * 100
        } else {
            percentage = (currentTotalThisYear - sumOfLastYearsDonations) / sumOfLastYearsDonations * 100
        }
        
        setupTotalGivenPerYearCard(notGivtModels!.map { $0.Value }.reduce(0, +) + givtModels!.map { $0.Value }.reduce(0, +), year)
        
        guard let givingGoal = givingGoal else {
            if weHavePastDonations {
                setupGivingGoalSmallSetupCard()
                setupGivingGoalPercentagePreviousYearCard(percentage, year == Date().getYear())
                showNoGivingGoalWithPreviousYearCards()
                return
            }
            setupGivingGoalBigSetupCard()
            showGivingGoalBigSetupCard()
            return
        }
        
        let givingGoalAmountPerYear = givingGoal.periodicity == 0 ? givingGoal.amount * 12 : givingGoal.amount
        let remainingGivingGoal = givingGoalAmountPerYear - currentTotalThisYear
        
        if isCurrentYear {
            setupGivingGoalPerYearCard(givingGoalAmountPerYear)
            if remainingGivingGoal > 0 {
                setupGivingGoalPerYearRemainingCard(remainingGivingGoal)
                showGivingGoalWithoutPreviousYearCards()
            } else {
                setupGivingGoalFinishedCard()
                showGivingGoalFinishedCard()
            }
            return
        }
        
        if weHavePastDonations {
            setupGivingGoalPerYearCard(givingGoalAmountPerYear)
            setupGivingGoalPercentagePreviousYearCard(percentage, false)
            givingGoalPercentagePreviousYearStackItem.constraints.first!.constant = 65
            showGivingGoalPerYearAndPercentCards()
            return
        }
        
        setupGivingGoalAmountBigCard(givingGoalAmountPerYear)
        showGivingGoalPerYearBigCard()
    }
    
}
