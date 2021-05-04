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
import SVProgressHUD

class BudgetOverviewViewController : UIViewController, OverlayHost {
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
    @IBOutlet weak var yearViewBodyHeight: NSLayoutConstraint!

    @IBOutlet weak var givingGoalView: UIView!
    @IBOutlet weak var givingGoalViewEditLabel: UILabel!
    @IBOutlet weak var givingGoalStackItem: BackgroundShadowView!
    
    @IBOutlet weak var remainingGivingGoalView: UIView!
    @IBOutlet weak var remainingGivingGoalStackItem: BackgroundShadowView!
    
    @IBOutlet weak var givingGoalSetupView: UIView!
    @IBOutlet weak var givingGoalSetupViewLabel: UILabel!
    @IBOutlet weak var givingGoalSetupStackItem: BackgroundShadowView!
    
    var originalHeightsSet = false
    var originalStackviewGivtHeight: CGFloat? = nil
    var originalStackviewNotGivtHeight: CGFloat? = nil
        
    var givingGoal: GivingGoal? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !SVProgressHUD.isVisible() {
            SVProgressHUD.show()
        }
        setupTerms()
        
        if !originalHeightsSet {
            originalStackviewGivtHeight = stackViewGivtHeight.constant
            originalStackviewNotGivtHeight = stackViewNotGivtHeight.constant
            originalHeightsSet = true
        }
        
        setupGivingGoalCard()
        
        if givingGoal != nil {
            givingGoalSetupStackItem.isHidden = true
            givingGoalStackItem.isHidden = false
            remainingGivingGoalStackItem.isHidden = false
        } else {
            givingGoalSetupStackItem.isHidden = false
            givingGoalStackItem.isHidden = true
            remainingGivingGoalStackItem.isHidden = true
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        setupCollectGroupsCard()
        setupMonthsCard()
        setupYearsCard()
        SVProgressHUD.dismiss()
        loadTestimonial()
    }
    
    
   
}
