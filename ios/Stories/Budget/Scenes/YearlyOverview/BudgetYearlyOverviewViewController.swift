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
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var labelGivt: UILabel!
    @IBOutlet weak var labelNotGivt: UILabel!
    @IBOutlet weak var labelTotal: UILabel!
    @IBOutlet weak var labelTax: UILabel!
    
    @IBOutlet weak var amountGivt: UILabel!
    @IBOutlet weak var amountNotGivt: UILabel!
    @IBOutlet weak var amountTotal: UILabel!
    @IBOutlet weak var amountTax: UILabel!
    
    var year: Int!
    
    var givtModels: [MonthlySummaryDetailModel]?
    var notGivtModels: [MonthlySummaryDetailModel]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !SVProgressHUD.isVisible() {
            SVProgressHUD.show()
        }
        
        setupTerms()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let fromDate = getStartDateForYear(year: year)
        let tillDate = getEndDateForYear(year: year)
        
        try! Mediater.shared.sendAsync(request: GetMonthlySummaryQuery(fromDate: fromDate, tillDate: tillDate, groupType: 2, orderType: 3)) { givtModels in
            DispatchQueue.main.async {
                self.givtModels = givtModels
                self.amountGivt.text = givtModels.map { $0.Value }.reduce(0, +).getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                self.amountTax.text = givtModels.filter { $0.TaxDeductable != nil && $0.TaxDeductable! }.map { $0.Value }.reduce(0, +).getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
            }
            
            try! Mediater.shared.sendAsync(request: GetExternalMonthlySummaryQuery(fromDate: fromDate , tillDate: tillDate, groupType: 2, orderType: 3)) { notGivtModels in
                self.notGivtModels = notGivtModels
                DispatchQueue.main.async {
                    self.amountNotGivt.text = notGivtModels.map { $0.Value }.reduce(0, +).getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                    self.amountTotal.text = (notGivtModels.map { $0.Value }.reduce(0, +) + givtModels.map { $0.Value }.reduce(0, +)).getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    @IBAction func goToYearlyOverviewDetail(_ sender: Any) {
        if !AppServices.shared.isServerReachable {
            try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
        } else {
            try? Mediater.shared.send(request: OpenYearlyOverviewDetailRoute(year: year, givtModels!, notGivtModels!, getStartDateForYear(year: year), getEndDateForYear(year: year)) , withContext: self)
        }
    }
}
