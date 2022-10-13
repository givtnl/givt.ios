//
//  SetupRecurringDonationOverviewViewController.swift
//  ios
//
//  Created by Jonas Brabant on 25/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import Foundation
import SVProgressHUD
import AppCenterAnalytics
import Mixpanel

class SetupRecurringDonationOverviewViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet var navBar: UINavigationItem!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var emptyListLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var recurringDonationsRuleOverview: UIView!
    @IBOutlet var createButton: CreateRecurringDonationButton!
    @IBOutlet var recurringDonationsOverviewTitleLabel: UILabel!
    
    public var reloadData: Bool = true;
    
    private var tempTableView: UITableView!
    var mediater: MediaterWithContextProtocol = Mediater.shared
    
    var recurringRules:[RecurringRuleViewModel] = []
    
    var frequencies = [
        "SetupRecurringGiftWeek".localized,
        "SetupRecurringGiftMonth".localized,
        "SetupRecurringGiftQuarter".localized,
        "SetupRecurringGiftHalfYear".localized,
        "SetupRecurringGiftYear".localized
    ]
    var selectedIndex: Int? = nil
    
    private var markedItem: RecurringRuleViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        navBar.title = "TitleRecurringGifts".localized
        createButton.label1.text = "RecurringGiftsSetupCreate".localized
        createButton.label2.text = "RecurringGiftsSetupRecurringGift".localized
        recurringDonationsOverviewTitleLabel.text = "OverviewRecurringDonations".localized
        tableView.delegate = self
        tableView.dataSource = self
        recurringDonationsRuleOverview.layer.cornerRadius = 8
        
        Analytics.trackEvent("RECURRING_DONATIONS_OVERVIEW_OPENED")
        
        Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_OVERVIEW_OPENED")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if reloadData {
            tableView.isHidden = true
            imageView.isHidden = false
            emptyListLabel.text = "EmptyRecurringDonationList".localized
            
            if !SVProgressHUD.isVisible() {
                SVProgressHUD.show()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !reloadData { return }
        
        do {
            // load collectgroups with query
            self.recurringRules = try self.mediater.send(request: GetRecurringDonationsQuery())
        } catch  {
            self.tableView.removeFromSuperview()
            self.stackView.addSubview(self.imageView)
        }
        
        if let item = markedItem {
            self.recurringRules.removeFirst()
            self.recurringRules.insert(item, at: 0)
        }
        
        tempTableView = tableView
        
        if self.recurringRules.count > 0 {
            
            if let view = self.imageView {
                self.tableView.isHidden = false
                view.isHidden = true
            }
            if let table = self.tempTableView {
                self.tableView = table
            }
            self.tableView.reloadData()
            self.stackView.addArrangedSubview(self.tableView)
            
        }
        reloadData = true;
        SVProgressHUD.dismiss()
    }
    
    @IBAction func createRecurringDonationButtonTapped(_ sender: Any) {
        resetSelectedIndex()
        try? mediater.send(request: GoToChooseRecurringDonationRoute(), withContext: self)
        Analytics.trackEvent("RECURRING_DONATIONS_CREATE_CLICKED")
        Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_CREATE_CLICKED")
    }
    
    @IBAction func backButton(_ sender: Any) {
        resetSelectedIndex()
        try? mediater.send(request: BackToMainRoute(), withContext: self)
        Analytics.trackEvent("RECURRING_DONATIONS_OVERVIEW_DISMISSED")
        Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_OVERVIEW_DISMISSED")
    }
}
