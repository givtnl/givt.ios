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
    private var mediater: MediaterWithContextProtocol = Mediater.shared
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(recurringDonationCreated), name: .GivtCreatedRecurringDonation, object: nil)
        
        navBar.title = "TitleRecurringGifts".localized
        createButton.label1.text = "RecurringGiftsSetupCreate".localized
        createButton.label2.text = "RecurringGiftsSetupRecurringGift".localized
        recurringDonationsOverviewTitleLabel.text = "OverviewRecurringDonations".localized
        tableView.delegate = self
        tableView.dataSource = self
        recurringDonationsRuleOverview.layer.cornerRadius = 8
        
        MSAnalytics.trackEvent("RECURRING_DONATIONS_OVERVIEW_OPENED")
        
        Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_OVERVIEW_OPENED")
    }
    
    @objc func recurringDonationCreated(notification: NSNotification) {
        try? mediater.sendAsync(request: GetRecurringDonationsQuery()) { response in
            self.recurringRules = response
            if var recurringRule = self.recurringRules.first {
                recurringRule.shouldShowNewItemMarker = true
                self.markedItem = recurringRule
            }
            NotificationManager.shared.areNotificationsEnabled(completion: { enabled in
                if (!enabled) {
                    DispatchQueue.main.async {
                        try? self.mediater.send(request: GoToPushNotificationViewRoute(), withContext: self)
                    }
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        MSAnalytics.trackEvent("RECURRING_DONATIONS_CREATE_CLICKED")
        Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_CREATE_CLICKED")
    }
    
    @IBAction func backButton(_ sender: Any) {
        resetSelectedIndex()
        try? mediater.send(request: BackToMainRoute(), withContext: self)
        MSAnalytics.trackEvent("RECURRING_DONATIONS_OVERVIEW_DISMISSED")
        Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_OVERVIEW_DISMISSED")
    }
}

extension SetupRecurringDonationOverviewViewController: RecurringRuleCancelDelegate, RecurringRuleListDelegate {
    func recurringRuleCancelTapped(recurringRuleCell: RecurringRuleTableCell) {
        MSAnalytics.trackEvent("RECURRING_DONATIONS_DONATION_STOP")
        Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_DONATION_STOP")
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "CancelRecurringDonationAlertTitle".localized.replacingOccurrences(of: "{0}", with: recurringRuleCell.nameLabel.text!), message: "CancelRecurringDonationAlertMessage".localized , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes".localized, style: .default, handler: { (action) in
                MSAnalytics.trackEvent("RECURRING_DONATIONS_DONATION_STOP_YES")
                Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_DONATION_STOP_YES")
                print("Cancel recurring donation: "+recurringRuleCell.nameLabel.text!)
                let command = CancelRecurringDonationCommand(recurringDonationId: recurringRuleCell.recurringDonationId!)
                do {
                    SVProgressHUD.show()
                    
                    try self.mediater.sendAsync(request: command) { canceled in
                        if(canceled) {
                            SVProgressHUD.dismiss()
                            self.recurringRules.removeAll { (model) -> Bool in
                                model.id == recurringRuleCell.recurringDonationId
                            }
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.selectedIndex = nil
                            }
                        } else {
                            SVProgressHUD.dismiss()
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "SomethingWentWrong".localized, message: "CancelRecurringDonationFailed".localized, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                }))
                                self.present(alert, animated: true, completion:  {})
                            }
                        }
                    }
                } catch  {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "SomethingWentWrong".localized, message: "CancelRecurringDonationFailed".localized, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        }))
                        self.present(alert, animated: true, completion:  {})
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "No".localized, style: .default, handler: {(action) in
                MSAnalytics.trackEvent("RECURRING_DONATIONS_DONATION_STOP_NO")
                Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_DONATION_STOP_NO")
            }))
            self.present(alert, animated: true, completion:  {})
        }
    }
    func recurringRuleListTapped(recurringRuleCell: RecurringRuleTableCell) {
        try? mediater.send(request: OpenRecurringDonationOverviewListRoute(recurringDonation: recurringRuleCell.viewModel!), withContext: self)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recurringRules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RecurringRuleTableCell.self), for: indexPath) as! RecurringRuleTableCell
        
        var rule = self.recurringRules[indexPath.row]
        
        do {
            let collectGroupDetailList: [CollectGroupDetailModel] = try mediater.send(request: GetCollectGroupsQuery())
            let collectGroupDetail: CollectGroupDetailModel = collectGroupDetailList.first(where: { $0.namespace == rule.namespace })!
            rule.collectGroupName = collectGroupDetail.name
            rule.collectGroupType = collectGroupDetail.type
            rule.indexPath = indexPath
        } catch
        {
            print(error)
        }
        cell.viewModel = rule
        
        cell.cancelDelegate = self
        cell.listDelegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndex == indexPath.row {
            selectedIndex = nil
        } else {
            selectedIndex = indexPath.row
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndex == indexPath.row {
            MSAnalytics.trackEvent("RECURRING_DONATIONS_DONATION_OPENED")
            Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_DONATION_OPENED")
            return 133
        } else {
            return 89
        }
    }
    private func resetSelectedIndex() {
        selectedIndex = nil
    }
}
