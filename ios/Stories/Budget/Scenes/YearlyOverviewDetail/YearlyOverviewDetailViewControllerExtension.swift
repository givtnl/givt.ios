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
        models.forEach { model in
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
        givtTableFooterTotalGivtAmountLabel.text = givtModels.map {$0.Value}.reduce(0, +).getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
        givtTableFooterDeductableAmountLabel.text = givtModels.filter {$0.TaxDeductable!}.map {$0.Value}.reduce(0, +).getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
    }
    
    func setupNotGivtModels() {
        setupTable(notGivtModels, notGivtStack, notGivtStackHeight)
        notGivtTableFooterTotalNotGivtAmountLabel.text = notGivtModels.map{$0.Value}.reduce(0, +).getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
    }
    
    func setupTotal() {
        let total = (givtModels.map {$0.Value}.reduce(0, +)) + (notGivtModels.map{$0.Value}.reduce(0, +))
        tableTotalAmountLabel.text = total.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
    }
    
    func setupTip() {
        roundCorners(view: tipView)
    }
    
    func setupTerms() {
        navItem.title = year.string
        givtTableHeaderTitleLabel.text = "Via Givt".localized
        givtTableHeaderAmountLabel.text = "Bedrag".localized
        givtTableHeaderDeductableLabel.text = "Aftrekbaar".localized
        givtTableFooterTotalGivtLabel.attributedText = createFooterTotalText(bold: "Totaal".localized, normal: "(via Givt)".localized)
        givtTableFooterDeductableLabel.text = "Totaal belastingsaftrekbaar".localized
        notGivtTableHeaderTitleLabel.text = "Niet via Givt".localized
        notGivtTableHeaderAmountLabel.text = "Bedrag".localized
        notGivtTableHeaderDeductableLabel.isHidden = true
        notGivtTableFooterTotalNotGivtLabel.attributedText = createFooterTotalText(bold: "Totaal".localized, normal: "(niet via Givt)".localized)
        tableTotalLabel.text = "Total".localized
        tipLabel.attributedText = createTipText(bold: "TIP: voeg je externe giften toe".localized, normal: "om een totaal overzicht te krijgen van wat je geeft, zowel via de Givt app als niet via de Givt app".localized)
        getByEmail.setTitle("Per mail ontvangen".localized, for: .normal)
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
