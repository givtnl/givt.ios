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

class BudgetYearlyOverviewViewController: UIViewController {
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
    
    @IBOutlet weak var givingGoalPerYearStackItem: BackgroundShadowView!
    @IBOutlet weak var givingGoalPerYearRemainingStackItem: BackgroundShadowView!
    @IBOutlet weak var givingGoalSmallSetupStackItem: BackgroundShadowView!
    @IBOutlet weak var givingGoalPercentagePreviousYearStackItem: BackgroundShadowView!
    @IBOutlet weak var givingGoalBigSetupStackItem: BackgroundShadowView!
    @IBOutlet weak var givingGoalPerYearBigStackItem: BackgroundShadowView!
    
    var currentIndex: Int? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if needsReload {
            if !SVProgressHUD.isVisible() {
                SVProgressHUD.show()
                hideView(mainView, true)
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
    }
}
