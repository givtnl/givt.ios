//
//  YearlyOverviewDetailViewControllerExtension.swift
//  ios
//
//  Created by Mike Pattyn on 10/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension BudgetYearlyOverviewDetailViewController {
    func setupTable(_ models: [MonthlySummaryDetailModel], _ stackView: UIStackView, _ stackViewHeight: NSLayoutConstraint) {
        var counter = 0
        models.sorted(by: { first, second in first.Key < second.Key }).forEach { model in
            let row = YearlyOverviewDetailLine()
            row.data = model
            if counter % 2 == 0 {
                row.backgroundView.backgroundColor = ColorHelper.BudgetYearlyOverviewDetailColoredRow
            }
            stackView.addArrangedSubview(row)
            stackViewHeight.constant += 30
            counter += 1
        }
    }
    func setupGivtModels() {
        setupTable(givtModels, givtStack, givtStackHeight)
        
        let sumTotal = givtModels.map {$0.Value}.reduce(0, +)
        let sumTaxDeductable = givtModels.filter {$0.TaxDeductable!}.map {$0.Value}.reduce(0, +)
        
        givtTableFooterTotalGivtAmountLabel.text = CurrencyHelper.shared.getLocalFormat(value: sumTotal.toFloat, decimals: true)
        givtTableFooterDeductableAmountLabel.text = CurrencyHelper.shared.getLocalFormat(value: sumTaxDeductable.toFloat, decimals: true)
    }
    
    func setupNotGivtModels() {
        setupTable(notGivtModels, notGivtStack, notGivtStackHeight)
        let sumTotal = notGivtModels.map{$0.Value}.reduce(0, +)
        let sumTaxDeductable = notGivtModels.filter {$0.TaxDeductable!}.map {$0.Value}.reduce(0, +)
        
        notGivtTableFooterTotalNotGivtAmountLabel.text = CurrencyHelper.shared.getLocalFormat(value: sumTotal.toFloat, decimals: true)
        notGivtTableFooterDeductableAmountLabel.text = CurrencyHelper.shared.getLocalFormat(value: sumTaxDeductable.toFloat, decimals: true)

    }
    
    func setupTotal() {
        let total = (givtModels.map {$0.Value}.reduce(0, +)) + (notGivtModels.map{$0.Value}.reduce(0, +))
        tableTotalAmountLabel.text = CurrencyHelper.shared.getLocalFormat(value: total.toFloat, decimals: true)
    }
    
    func setupTip() {
        if year != Date().getYear() {
            tipView.superview?.superview?.removeFromSuperview()
            totalRowView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
            return
        }
        roundCorners(view: tipView)
        
    }
    
    func setupTerms() {
        navItem.title = year.string
        givtTableHeaderTitleLabel.text = "BudgetYearlyOverviewDetailThroughGivt".localized
        givtTableHeaderAmountLabel.text = "BudgetYearlyOverviewDetailAmount".localized
        givtTableHeaderDeductableLabel.text = "BudgetYearlyOverviewDetailDeductable".localized
        givtTableFooterTotalGivtLabel.attributedText = createFooterTotalText(bold: "BudgetYearlyOverviewDetailTotal".localized, normal: "BudgetYearlyOverviewDetailTotalThroughGivt".localized)
        givtTableFooterDeductableLabel.text = "BudgetYearlyOverviewDetailTotalDeductable".localized
        notGivtTableHeaderTitleLabel.text = "BudgetYearlyOverviewDetailNotThroughGivt".localized
        notGivtTableHeaderAmountLabel.text = "BudgetYearlyOverviewDetailAmount".localized
        notGivtTableHeaderDeductableLabel.text = "BudgetYearlyOverviewDetailDeductable".localized
        notGivtTableFooterTotalNotGivtLabel.attributedText = createFooterTotalText(bold: "BudgetYearlyOverviewDetailTotal".localized, normal: "BudgetYearlyOverviewDetailTotalNotThroughGivt".localized)
        notGivtTableFooterDeductableLabel.text = "BudgetYearlyOverviewDetailTotalDeductable".localized
        tableTotalLabel.text = "BudgetYearlyOverviewDetailTotal".localized
        tipLabel.attributedText = createTipText(bold: "BudgetYearlyOverviewDetailTipBold".localized, normal: "BudgetYearlyOverviewDetailTipNormal".localized)
        getByEmail.setTitle("BudgetYearlyOverviewDetailReceiveViaMail".localized, for: .normal)
    }
    
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
    
    func createFooterTotalText(bold: String, normal: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString()
            .bold(bold.localized + " ", font: UIFont(name: "Avenir-Heavy", size: 14)!)
            .normal(normal.localized, font: UIFont(name: "Avenir-Light", size: 14)!)
        return attributedString
    }
    
    func createTipText(bold: String, normal: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString()
            .bold(bold.localized + "\n", font: UIFont(name: "Avenir-Black", size: 12)!)
            .normal(normal.localized, font: UIFont(name: "Avenir-Medium", size: 12)!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.maximumLineHeight = 14
        paragraphStyle.minimumLineHeight = 14
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        return attributedString
    }
}
