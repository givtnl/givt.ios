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
struct YearChartValue {
    var year: Int
    var value: Double
}
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
    var givingGoalAmount: Double? = nil
    
    @IBOutlet weak var givingGoalPerMonthText: UILabel!
    @IBOutlet weak var givingGoalPerMonthInfo: UILabel!
    @IBOutlet weak var givingGoalRemaining: UILabel!
    @IBOutlet weak var givingGoalRemainingInfo: UILabel!
    
    @IBOutlet weak var setupGivingGoalLabel: UILabel!
    
    var lastMonthTotal: Double? = nil
    
    @IBOutlet weak var yearBarOneStackItem: UIView!
    @IBOutlet weak var yearBarTwoStackItem: UIView!
    @IBOutlet weak var yearBarOneParent: UIView!
    @IBOutlet weak var yearBarOne: YearViewBodyLine!
    @IBOutlet weak var yearBarOneLabel: UILabel!
    @IBOutlet weak var yearBarTwo: YearViewBodyLine!
    @IBOutlet weak var yearBarTwoLabel: UILabel!
    @IBOutlet weak var yearBarOneOutsideValueLabel: UILabel!
    @IBOutlet weak var yearBarTwoOutsideValueLabel: UILabel!
    
    var collectGroupsForCurrentMonth: [MonthlySummaryDetailModel]? = nil
    var notGivtModelsForCurrentMonth: [ExternalDonationModel]? = nil
    
    var monthlySummaryModels: [MonthlySummaryDetailModel]? = nil
    var monthlySummaryModelsNotGivt: [MonthlySummaryDetailModel]? = nil
    
    var yearlySummary: [MonthlySummaryDetailModel]? = nil
    var yearlySummaryNotGivt: [MonthlySummaryDetailModel]? = nil
    
    var amountOutsideLabel: CGRect? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadData() {
        collectGroupsForCurrentMonth = try! Mediater.shared.send(request: GetMonthlySummaryQuery(fromDate: getFromDateForCurrentMonth(),tillDate: getTillDateForCurrentMonth(), groupType: 2, orderType: 3))
        
        notGivtModelsForCurrentMonth = try! Mediater.shared.send(request: GetAllExternalDonationsQuery(fromDate: getFromDateForCurrentMonth(),tillDate: getTillDateForCurrentMonth())).result.sorted(by: { first, second in
            first.creationDate > second.creationDate
        })
        
        monthlySummaryModels = try! Mediater.shared.send(request: GetMonthlySummaryQuery(fromDate: getFromDateForMonthsChart(), tillDate: getTillDateForMonthsChart(), groupType: 0, orderType: 0))
        
        monthlySummaryModelsNotGivt = try! Mediater.shared.send(request: GetExternalMonthlySummaryQuery(fromDate: getFromDateForMonthsChart(), tillDate: getTillDateForMonthsChart(), groupType: 0, orderType: 0))
        
        yearlySummary = try! Mediater.shared.send(request: GetMonthlySummaryQuery(fromDate: getFromDateForYearlyOverview(), tillDate: getTillDateForCurrentMonth(), groupType: 1, orderType: 0))
        
        yearlySummaryNotGivt = try! Mediater.shared.send(request: GetExternalMonthlySummaryQuery(fromDate: getFromDateForYearlyOverview(), tillDate: getTillDateForCurrentMonth(), groupType: 1, orderType: 0))
        
        givingGoal = try! Mediater.shared.send(request: GetGivingGoalQuery()).result
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !SVProgressHUD.isVisible() {
            SVProgressHUD.show()
        }
        
        loadData()
        
        setupTerms()
        
        if !originalHeightsSet {
            originalStackviewGivtHeight = stackViewGivtHeight.constant
            originalStackviewNotGivtHeight = stackViewNotGivtHeight.constant
            originalHeightsSet = true
        }
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupGivingGoalCard()
        setupCollectGroupsCard()
        setupMonthsCard()
        
        if givingGoal != nil {
            let currentGivenPerMonth = lastMonthTotal!
            
            var remainingThisMonth = givingGoalAmount! - currentGivenPerMonth
            
            remainingThisMonth = remainingThisMonth >= 0 ? remainingThisMonth : 0
            
            givingGoalRemaining.text = remainingThisMonth.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
        }
        
        setupYearsCard()
        
        setupTestimonial()

        SVProgressHUD.dismiss()
        
    }
}
