//
//  BudgetViewController.swift
//  ios
//
//  Created by Mike Pattyn on 09/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//
import Charts
import Foundation
import UIKit

class BudgetViewController : UIViewController {
    var mediater: MediaterWithContextProtocol = Mediater.shared
    
    @IBOutlet weak var monthlySummaryTile: MonthlySummary!
    
    @IBOutlet weak var givtNowButton: CustomButton!
    
    @IBOutlet weak var monthlyCardHeader: CardViewHeader!
    
    @IBOutlet weak var labelGivt: UILabel!
    @IBOutlet weak var stackViewGivt: UIStackView!
    
    @IBOutlet weak var viewBorder: UIView!
    
    @IBOutlet weak var labelNotGivt: UILabel!
    @IBOutlet weak var stackViewNotGivt: UIStackView!
    
    @IBOutlet weak var buttonSeeMore: UIButton!
    @IBOutlet weak var buttonPlus: CustomButton!
    
    @IBOutlet weak var stackViewGivtHeight: NSLayoutConstraint!
    @IBOutlet weak var stackViewNotGivtHeight: NSLayoutConstraint!
        
    @IBOutlet weak var chartViewHeader: CardViewHeader!
    @IBOutlet weak var chartViewBody: ChartViewBody!
    
    @IBOutlet weak var yearViewHeader: CardViewHeader!
    @IBOutlet weak var yearViewBody: YearViewBody!
    
    
    // stuff for the chart
        
    override func viewDidLoad() {
        monthlySummaryTile.descriptionLabel.text = "BudgetSummaryBalance".localized
        givtNowButton.setTitle("BudgetSummaryGiveNow".localized, for: .normal)
        
        monthlyCardHeader.label.text = getFullMonthStringFromDateValue(value: Date()).capitalized
        navigationItem.title = getFullMonthStringFromDateValue(value: Date()).capitalized
        chartViewHeader.label.text = "BudgetSummaryMonth".localized
        yearViewHeader.label.text = "BudgetSummaryYear".localized
        labelGivt.text = "BudgetSummaryGivt".localized
        labelNotGivt.text = "BudgetSummaryNotGivt".localized
        buttonSeeMore.setAttributedTitle(NSMutableAttributedString(string: "BudgetSummaryShowAll".localized,
                                      attributes: [NSAttributedString.Key.underlineStyle : true]), for: .normal)
        buttonSeeMore.setTitleColor(ColorHelper.SummaryLightGray, for: .normal)
        buttonPlus.ogBGColor = ColorHelper.LightGreenChart
        viewBorder.backgroundColor = ColorHelper.SummaryLightGray
        // delegates for chart formatters
        setupTesting()
        setupCollectGroupsCard()
        setupMonthsCard()
        setupYearsCard()
    }

    
    private func setupTesting() {
//        let noGivtsYet = MonthlyCardViewLine()
//        stackViewGivt.addArrangedSubview(noGivtsYet)
//        stackViewGivtHeight.constant += 22
//        let noGivtsYet2 = MonthlyCardViewLine()
//        stackViewGivt.addArrangedSubview(noGivtsYet2)
//        stackViewGivtHeight.constant += 22
        
        let noGivtsYet3 = MonthlyCardViewLine()
        noGivtsYet3.collectGroupLabel.text = "Nog geen giften"
        stackViewNotGivt.addArrangedSubview(noGivtsYet3)
        stackViewNotGivtHeight.constant += 22
        let noGivtsYet4 = MonthlyCardViewLine()
        noGivtsYet4.collectGroupLabel.text = "Nog geen giften"
        stackViewNotGivt.addArrangedSubview(noGivtsYet4)
        stackViewNotGivtHeight.constant += 22
        
    }
}


