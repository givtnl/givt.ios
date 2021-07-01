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

protocol DeltaChangedDelegate: AnyObject {
    func onReceiveDeltaChanged()
}

class BudgetOverviewViewController : BaseTrackingViewController, OverlayHost, DeltaChangedDelegate {
    
    func onReceiveDeltaChanged() {
        trackEvent("LOADED", properties: ["DELTA": delta])
    }
    
    override var screenName: String  { return "PersonalSummary" }
    
    var delta = 0
    var deltaDelegate: DeltaChangedDelegate?
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
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
    @IBOutlet weak var yearCardView: BackgroundShadowView!
    @IBOutlet weak var yearViewHeader: CardViewHeader!
    @IBOutlet weak var yearViewBody: YearViewBody!
    
    @IBOutlet weak var buttonControlView: UIView!
    @IBOutlet weak var buttonAddExternalDonationView: UIView!
    @IBOutlet weak var givingGoalView: UIView!
    @IBOutlet weak var givingGoalViewEditLabel: UILabel!
    @IBOutlet weak var givingGoalStackItem: BackgroundShadowView!
    
    @IBOutlet weak var remainingGivingGoalView: UIView!
    @IBOutlet weak var remainingGivingGoalStackItem: BackgroundShadowView!
    
    @IBOutlet weak var givingGoalSetupView: UIView!
    @IBOutlet weak var givingGoalSetupViewLabel: UILabel!
    @IBOutlet weak var givingGoalSetupStackItem: BackgroundShadowView!
    
    @IBOutlet weak var givingGoalReachedView: UIView!
    @IBOutlet weak var givingGoalReachedLabel: UILabel!
    @IBOutlet weak var givingGoalReachedStackItem: BackgroundShadowView!
    
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
    
    @IBOutlet weak var yearBarsStack: UIStackView!
    @IBOutlet weak var yearBarOneStackItem: UIView!
    @IBOutlet weak var yearBarTwoStackItem: UIView!
    @IBOutlet weak var yearBarOneParent: UIView!
    @IBOutlet weak var yearBarOne: YearViewBodyLine!
    @IBOutlet weak var yearBarOneLabel: UILabel!
    @IBOutlet weak var yearBarTwo: YearViewBodyLine!
    @IBOutlet weak var yearBarTwoLabel: UILabel!
    @IBOutlet weak var yearOneTapView: YearUIView!
    @IBOutlet weak var yearTwoTapView: YearUIView!
    
    var collectGroupsForCurrentMonth: [MonthlySummaryDetailModel]? = nil
    var notGivtModelsForCurrentMonth: [ExternalDonationModel]? = nil
    
    var monthlySummaryModels: [MonthlySummaryDetailModel]? = nil
    var monthlySummaryModelsNotGivt: [MonthlySummaryDetailModel]? = nil
    
    var yearlySummary: [MonthlySummaryDetailModel]? = nil
    var yearlySummaryNotGivt: [MonthlySummaryDetailModel]? = nil
    
    var amountOutsideLabel: CGRect? = nil
    
    var fromMonth: Date!
    
    @IBOutlet weak var monthSelectorButtonLeft: UIButton!
    @IBOutlet weak var monthSelectorLabel: UILabel!
    @IBOutlet weak var monthSelectorButtonRight: UIButton!
    
    var needsReload = true

    override func viewDidLoad() {
        customTrackingProperties = ["DELTA": delta]
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deltaDelegate = self
        if needsReload {
            if !SVProgressHUD.isVisible() {
                SVProgressHUD.show()
                hideView(mainView, true)
            }
            
            setupTerms()
            
            if !originalHeightsSet {
                originalStackviewGivtHeight = stackViewGivtHeight.constant
                originalStackviewNotGivtHeight = stackViewNotGivtHeight.constant
                originalHeightsSet = true
            }
            
            setupMonthPicker()
            
            roundCorners(view: givingGoalView)
            roundCorners(view: remainingGivingGoalView)
            roundCorners(view: givingGoalSetupView)
            roundCorners(view: givingGoalReachedView)
            
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if needsReload {
            // MARK: Giving goal
            givingGoal = try! Mediater.shared.send(request: GetGivingGoalQuery()).result
            setupGivingGoalCard()
            
            
            // MARK: Collect groups card
            collectGroupsForCurrentMonth = try! Mediater.shared.send(request: GetMonthlySummaryQuery(fromDate: self.getStartDateOfMonth(date: self.fromMonth),tillDate: self.getEndDateOfMonth(date: self.fromMonth), groupType: 2, orderType: 3))
            notGivtModelsForCurrentMonth = try! Mediater.shared.send(request: GetAllExternalDonationsQuery(fromDate: self.getStartDateOfMonth(date: self.fromMonth),tillDate: self.getEndDateOfMonth(date: self.fromMonth))).result.sorted(by: { first, second in
                first.creationDate > second.creationDate
            })
            setupCollectGroupsCard()
            
            monthlySummaryTile.amountLabel.text = getMonthlySum().getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
            
            setupCollectGroupsCard()
            
            // MARK: Per month chart
            monthlySummaryModels = try! Mediater.shared.send(request: GetMonthlySummaryQuery(fromDate: getFromDateForMonthsChart(), tillDate: getTillDateForMonthsChart(), groupType: 0, orderType: 0))
            monthlySummaryModelsNotGivt = try! Mediater.shared.send(request: GetExternalMonthlySummaryQuery(fromDate: getFromDateForMonthsChart(), tillDate: getTillDateForMonthsChart(), groupType: 0, orderType: 0))
            setupMonthsCard()
            
            // MARK: Yearly Chart
            yearlySummary = try! Mediater.shared.send(request: GetMonthlySummaryQuery(fromDate: getFromDateForYearlyOverview(), tillDate: getTillDateForCurrentMonth(), groupType: 1, orderType: 0))
            yearlySummaryNotGivt = try! Mediater.shared.send(request: GetExternalMonthlySummaryQuery(fromDate: getFromDateForYearlyOverview(), tillDate: getTillDateForCurrentMonth(), groupType: 1, orderType: 0))
            setupYearsCard()
            
            // MARK: Testimonial
            setupTestimonial()
            
            setupRemainingGivingGoal(getMonthlySum())
            
            SVProgressHUD.dismiss()
            hideView(mainView, false)
        }
    }
}
