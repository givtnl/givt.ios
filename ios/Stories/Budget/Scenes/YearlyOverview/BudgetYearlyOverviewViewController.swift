//
//  BudgetYearlyOverviewViewController.swift
//  ios
//
//  Created by Mike Pattyn on 04/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class BudgetYearlyOverviewViewController: BaseTrackingViewController {
    override var screenName: String { return "YearlySummary" }

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var labelGivt: UILabel!
    @IBOutlet weak var labelNotGivt: UILabel!
    @IBOutlet weak var labelTotal: UILabel!
    @IBOutlet weak var labelTax: UILabel!
    
    @IBOutlet weak var amountGivt: UILabel!
    @IBOutlet weak var amountNotGivt: UILabel!
    @IBOutlet weak var amountTotal: UILabel!
    @IBOutlet weak var amountTax: UILabel!
    
    @IBOutlet weak var downloadButton: CustomButton!
    
    var year: Int!
    
    var givtModels: [MonthlySummaryDetailModel]?
    var notGivtModels: [MonthlySummaryDetailModel]?
    
    var previousYearGivtModels: [MonthlySummaryDetailModel] = []
    var previousYearNotGivtModels: [MonthlySummaryDetailModel] = []
    
    var needsReload = true
    @IBOutlet weak var totalGivenPerYearAmountLabel: UILabel!
    @IBOutlet weak var totalGivenPerYearAmountDescription: UILabel!
    
    @IBOutlet weak var givingGoalPerYearAmountLabel: UILabel!
    @IBOutlet weak var givingGoalPerYearDescriptionLabel: UILabel!
    @IBOutlet weak var givingGoalPerYearEditGivingGoalLabel: UILabel!
    @IBOutlet weak var givingGoalPerYearRemainingAmountLabel: UILabel!
    @IBOutlet weak var givingGoalPerYearRemainingDescriptionLabel: UILabel!
    @IBOutlet weak var givingGoalSetupSmallLabel: UILabel!
    @IBOutlet weak var givingGoalPercentagePreviousYearAmountLabel: UILabel!
    @IBOutlet weak var givingGoalPercentagePreviousYearDescriptionLabel: UILabel!
    @IBOutlet weak var givingGoalBigSetupLabel: UILabel!
    @IBOutlet weak var givingGoalBigAmountLabel: UILabel!
    @IBOutlet weak var givingGoalBigDescriptionLabel: UILabel!
    @IBOutlet weak var givingGoalFinishedLabel: UILabel!
    
    @IBOutlet weak var givingGoalPerYearStackItem: BackgroundShadowView!
    @IBOutlet weak var givingGoalPerYearRemainingStackItem: BackgroundShadowView!
    @IBOutlet weak var givingGoalSmallSetupStackItem: BackgroundShadowView!
    @IBOutlet weak var givingGoalPercentagePreviousYearStackItem: BackgroundShadowView!
    @IBOutlet weak var givingGoalBigSetupStackItem: BackgroundShadowView!
    @IBOutlet weak var givingGoalPerYearBigStackItem: BackgroundShadowView!
    @IBOutlet weak var givingGoalFinishedStackItem: BackgroundShadowView!
    
    @IBOutlet weak var monthlyBarsStackView: UIStackView!
    @IBOutlet weak var monthlyBarsStackViewHeight: NSLayoutConstraint!
    
    var currentIndex: Int? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if needsReload {
            hideView(mainView, true)

            if !SVProgressHUD.isVisible() {
                SVProgressHUD.show()
            }
            setupTerms()
            
            hideStatisticsStackItems()
            showGivingGoalWithoutPreviousYearCards()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if needsReload {
            reloadData()
        }
        
        var givtNumbers: [Int: Double] = [:]
        var notGivtNumbers: [Int: Double] = [:]
        
        for int in 0...8 {
            givtNumbers[int] = Double.random(in: 5...100)
            notGivtNumbers[int] = Double.random(in: 5...100)
        }
        
        var highestAmount = 0.0
        for int in 0...8 {
            let sum = givtNumbers[int]! + notGivtNumbers[int]!
            if sum > highestAmount {
                highestAmount = sum
            }
        }
        
        var models: [Int: MonthlyBarViewModel] = [:]
        for int in 0...8 {
            models[int] = MonthlyBarViewModel(givtAmount: givtNumbers[int]!, notGivtAmount: notGivtNumbers[int]!, highestAmount: highestAmount, maxBarWidth: (self.view.frame.width - 80.00), date: Date())
            
        }
        
        getDataForMonthBars() { bars in
            DispatchQueue.main.async {
                bars.forEach { bar in
                    bar.highestAmount = bars.highestBarValue
                    bar.maxBarWidth = (self.view.frame.width - 80.00)
                }
                self.loadMonthBars(monthBars: bars.sorted(by: { first, second in
                    first.date! < second.date!
                }))
            }
        }
        
        
    }
}
