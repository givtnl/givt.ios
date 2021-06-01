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
    
    @IBOutlet weak var yearBarOneStackItem: UIView!
    @IBOutlet weak var yearBarTwoStackItem: UIView!
    @IBOutlet weak var yearBarOneParent: UIView!
    @IBOutlet weak var yearBarOne: YearViewBodyLine!
    @IBOutlet weak var yearBarOneLabel: UILabel!
    @IBOutlet weak var yearBarTwo: YearViewBodyLine!
    @IBOutlet weak var yearBarTwoLabel: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !SVProgressHUD.isVisible() {
            SVProgressHUD.show()
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // MARK: Collect groups card
        collectGroupsForCurrentMonth = try! Mediater.shared.send(request: GetMonthlySummaryQuery(fromDate: getFromDateForCurrentMonth(),tillDate: getTillDateForCurrentMonth(), groupType: 2, orderType: 3))
        
        notGivtModelsForCurrentMonth = try! Mediater.shared.send(request: GetAllExternalDonationsQuery(fromDate: getFromDateForCurrentMonth(),tillDate: getTillDateForCurrentMonth())).result.sorted(by: { first, second in
            first.creationDate > second.creationDate
        })
        
        setupCollectGroupsCard()
        
        // MARK: Per month chart
        
        monthlySummaryModels = try! Mediater.shared.send(request: GetMonthlySummaryQuery(fromDate: getFromDateForMonthsChart(), tillDate: getTillDateForMonthsChart(), groupType: 0, orderType: 0))
        
        monthlySummaryModelsNotGivt = try! Mediater.shared.send(request: GetExternalMonthlySummaryQuery(fromDate: getFromDateForMonthsChart(), tillDate: getTillDateForMonthsChart(), groupType: 0, orderType: 0))
        
        setupMonthsCard()
        
        // MARK: Giving goal
        
        givingGoal = try! Mediater.shared.send(request: GetGivingGoalQuery()).result
        
        setupGivingGoalCard()
        
        // MARK: Yearly Chart
        
        yearlySummary = try! Mediater.shared.send(request: GetMonthlySummaryQuery(fromDate: getFromDateForYearlyOverview(), tillDate: getTillDateForCurrentMonth(), groupType: 1, orderType: 0))
        
        yearlySummaryNotGivt = try! Mediater.shared.send(request: GetExternalMonthlySummaryQuery(fromDate: getFromDateForYearlyOverview(), tillDate: getTillDateForCurrentMonth(), groupType: 1, orderType: 0))
        
        setupYearsCard()
        
        setupTestimonial()
        
        SVProgressHUD.dismiss()
        
    }
    @IBAction func goBackOneMonth(_ sender: Any) {
        fromMonth = getPreviousMonth(from: fromMonth)
        
        updateMonthCard()
    }
    @IBAction func goForwardOneMonth(_ sender: Any) {
        fromMonth = getNextMonth(from: fromMonth)
        
        updateMonthCard()
    }
    func updateMonthCard() {
        
        // MARK: Collect groups card
        
        SVProgressHUD.show()
        
        try! Mediater.shared.sendAsync(request: GetMonthlySummaryQuery(fromDate: self.getStartDateOfMonth(date: self.fromMonth),tillDate: self.getEndDateOfMonth(date: self.fromMonth), groupType: 2, orderType: 3)) { givtResponse in
            self.collectGroupsForCurrentMonth = givtResponse
            try! Mediater.shared.sendAsync(request: GetAllExternalDonationsQuery(fromDate: self.getStartDateOfMonth(date: self.fromMonth),tillDate: self.getEndDateOfMonth(date: self.fromMonth))) { notGivtResponse in
                self.notGivtModelsForCurrentMonth = notGivtResponse.result.sorted(by: { first, second in
                    first.creationDate > second.creationDate
                })
                DispatchQueue.main.async {
                    self.monthSelectorLabel.text = self.getFullMonthStringFromDateValue(value: self.fromMonth).capitalized
                    self.setupCollectGroupsCard()
                    self.monthlySummaryTile.amountLabel.text = self.getMonthlySum().getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                    self.setupGivingGoalCard(self.getMonthlySum())
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    func getMonthlySum() -> Double {
        let amountValuesGivt: [Double] = collectGroupsForCurrentMonth!.map { $0.Value }
        let amountValuesNotGivt: [Double] = notGivtModelsForCurrentMonth!.map { $0.amount }
        return amountValuesGivt.reduce(0, +) + amountValuesNotGivt.reduce(0, +)
    }
    func getPreviousMonth(from: Date) -> Date  {
        var dateComponent = DateComponents()
        dateComponent.month = -1
        return Calendar.current.date(byAdding: dateComponent, to: from)!
    }
    func getNextMonth(from: Date) -> Date {
        var dateComponent = DateComponents()
        dateComponent.month = 1
        return Calendar.current.date(byAdding: dateComponent, to: from)!
    }
    
    func getStartDateOfMonth(date: Date) -> String {
        let calendar = Calendar.current
        let currentYear = Calendar.current.component(.year, from: date)
        let currentMonth = Calendar.current.component(.month, from: date)
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = currentMonth
        dateComponents.day = 1
        let date = calendar.date(from: dateComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    func getEndDateOfMonth(date: Date) -> String {
        let calendar = Calendar.current
        let currentYear = Calendar.current.component(.year, from: date)
        let currentMonth = Calendar.current.component(.month, from: date) + 1
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = currentMonth
        dateComponents.day = -1
        let date = calendar.date(from: dateComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
}
