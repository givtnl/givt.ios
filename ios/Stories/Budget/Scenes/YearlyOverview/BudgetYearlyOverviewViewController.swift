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
            
            setupTotalGivenPerYearCard()
            
            setupGivingGoalPerYearCard()
            setupGivingGoalPerYearRemainingCard()

            setupGivingGoalSmallSetupCard()
            setupGivingGoalPercentagePreviousYearCard()
            
            setupGivingGoalBigSetupCard()
            
            setupGivingGoalAmountBigCard()
            
            hideStatisticsStackItems()
            showGivingGoalWithoutPreviousYearCards()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if needsReload {
            let fromDate = getStartDateForYear(year: year)
            let tillDate = getEndDateForYear(year: year)
            
            try! Mediater.shared.sendAsync(request: GetMonthlySummaryQuery(fromDate: fromDate, tillDate: tillDate, groupType: 2, orderType: 3)) { givtModels in
                DispatchQueue.main.async {
                    self.givtModels = givtModels
                    self.amountGivt.text = givtModels.map { $0.Value }.reduce(0, +).getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                   
                }
                
                try! Mediater.shared.sendAsync(request: GetExternalMonthlySummaryQuery(fromDate: fromDate , tillDate: tillDate, groupType: 2, orderType: 3)) { notGivtModels in
                    self.notGivtModels = notGivtModels
                    DispatchQueue.main.async {
                        self.amountNotGivt.text = notGivtModels.map { $0.Value }.reduce(0, +).getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                        self.amountTotal.text = (notGivtModels.map { $0.Value }.reduce(0, +) + givtModels.map { $0.Value }.reduce(0, +)).getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                        
                        let givtAmountTax = givtModels.filter { $0.TaxDeductable != nil && $0.TaxDeductable! }.map { $0.Value }.reduce(0, +)
                        let notGivtAmountTax = notGivtModels.filter { $0.TaxDeductable != nil && $0.TaxDeductable! }.map { $0.Value }.reduce(0, +)
                        self.amountTax.text = (givtAmountTax + notGivtAmountTax).getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                        
                        SVProgressHUD.dismiss()
                        self.hideView(self.mainView, false)

                    }
                }
            }
        }
    }
    
    @IBAction func goToYearlyOverviewDetail(_ sender: Any) {
        if currentIndex == nil {
            currentIndex = 0
        }
        
        hideStatisticsStackItems()

        if currentIndex == 0 {
            showNoGivingGoalWithPreviousYearCards()
            currentIndex = 1
        } else if currentIndex == 1{
            showGivingGoalBigSetupCard()
            currentIndex = 2
        } else if currentIndex == 2 {
            showGivingGoalPerYearBigCard()
            currentIndex = 3
        } else if currentIndex == 3 {
            showGivingGoalWithoutPreviousYearCards()
            currentIndex = 0
        }
//        if !AppServices.shared.isServerReachable {
//            try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
//        } else {
//            try? Mediater.shared.send(request: OpenYearlyOverviewDetailRoute(year: year, givtModels!, notGivtModels!, getStartDateForYear(year: year), getEndDateForYear(year: year)) , withContext: self)
//        }
    }
}
