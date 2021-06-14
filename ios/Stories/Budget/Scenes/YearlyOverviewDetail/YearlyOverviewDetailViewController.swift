//
//  YearlyOverviewDetailViewController.swift
//  ios
//
//  Created by Mike Pattyn on 10/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class BudgetYearlyOverviewDetailViewController: UIViewController {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var totalRowView: UIView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var givtStack: UIStackView!
    @IBOutlet weak var givtStackHeight: NSLayoutConstraint!
    @IBOutlet weak var notGivtStack: UIStackView!
    @IBOutlet weak var notGivtStackHeight: NSLayoutConstraint!
    
    var year: Int!
    var givtModels: [MonthlySummaryDetailModel]!
    var notGivtModels: [MonthlySummaryDetailModel]!
    var fromDate: String!
    var tillDate: String!
    
    @IBOutlet weak var givtTableHeaderTitleLabel: UILabel!
    @IBOutlet weak var givtTableHeaderAmountLabel: UILabel!
    @IBOutlet weak var givtTableHeaderDeductableLabel: UILabel!
    @IBOutlet weak var givtTableFooterTotalGivtLabel: UILabel!
    @IBOutlet weak var givtTableFooterTotalGivtAmountLabel: UILabel!
    @IBOutlet weak var givtTableFooterDeductableLabel: UILabel!
    @IBOutlet weak var givtTableFooterDeductableAmountLabel: UILabel!
    
    @IBOutlet weak var notGivtTableHeaderTitleLabel: UILabel!
    @IBOutlet weak var notGivtTableHeaderAmountLabel: UILabel!
    @IBOutlet weak var notGivtTableHeaderDeductableLabel: UILabel!
    @IBOutlet weak var notGivtTableFooterTotalNotGivtLabel: UILabel!
    @IBOutlet weak var notGivtTableFooterTotalNotGivtAmountLabel: UILabel!
    
    @IBOutlet weak var tableTotalLabel: UILabel!
    @IBOutlet weak var tableTotalAmountLabel: UILabel!
    
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var getByEmail: CustomButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !SVProgressHUD.isVisible() {
            SVProgressHUD.show()
            hideView(mainView, true)
        }
        
        setupTerms()
        setupGivtModels()
        setupNotGivtModels()
        setupTotal()
        setupTip()
        
        getByEmail.isEnabled = !(givtModels.count == 0 && notGivtModels.count == 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if SVProgressHUD.isVisible() {
            SVProgressHUD.dismiss()
            hideView(mainView, false)
        }
    }
}
