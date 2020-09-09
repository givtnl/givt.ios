//
//  HomeScreenRecurringDonationViewController.swift
//  ios
//
//  Created by Jonas Brabant on 25/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import Foundation
import SVProgressHUD

class HomeScreenRecurringDonationViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet var navBar: UINavigationItem!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var emptyListLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var recurringDonationsRuleOverview: UIView!
    @IBOutlet var createButton: CreateRecurringDonationButton!
    @IBOutlet var recurringDonationsOverviewTitleLabel: UILabel!
    
    private var tempTableView: UITableView!
    private var mediater: MediaterWithContextProtocol = Mediater.shared
    
    var recurringRules:[RecurringRuleViewModel] = []
    var frequencies = ["SetupRecurringGiftWeek".localized, "SetupRecurringGiftMonth".localized, "SetupRecurringGiftQuarter".localized, "SetupRecurringGiftHalfYear".localized, "SetupRecurringGiftYear".localized]
    var selectedIndex: Int? = nil
    
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
    }
    
    @objc func recurringDonationCreated(notification: NSNotification) {
        do {
            recurringRules = try mediater.send(request: GetRecurringDonationsQuery())
            if let recurringDonationId = notification.userInfo?["recurringDonationId"] as? String {
                if var recurringRule = recurringRules.first(where: { (model) -> Bool in model.id.lowercased() == recurringDonationId.lowercased() }) {
                    recurringRule.shouldShowNewItemMarker = true
                    recurringRules.remove(at: 0)
                    recurringRules.insert(recurringRule, at: 0)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        } catch {
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        do {
            // load collectgroups with query
            
            recurringRules = try mediater.send(request: GetRecurringDonationsQuery())
            
            if recurringRules.count == 0 {
                tempTableView = tableView
                tableView.isHidden = true
                imageView.isHidden = false
                emptyListLabel.text = "EmptySubscriptionList".localized
            } else {
                if let view = imageView {
                    tableView.isHidden = false
                    view.isHidden = true
                }
                if let table = tempTableView {
                    tableView = table
                }
                tableView.reloadData()
                stackView.addArrangedSubview(tableView)
            }
        } catch  {
            tableView.removeFromSuperview()
            stackView.addSubview(self.imageView)
        }
    }
    
    @IBAction func createRecurringDonationButtonTapped(_ sender: Any) {
        try? mediater.send(request: GoToChooseRecurringDonationRoute(), withContext: self)
    }
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: BackToMainRoute(), withContext: self)
    }
}

extension HomeScreenRecurringDonationViewController: RecurringRuleCencelDelegate {
    func recurringRuleCancelTapped(recurringRuleCell: RecurringRuleTableCell) {
        print("Cancel recurring donation: "+recurringRuleCell.nameLabel.text!)
        let command = CancelRecurringDonationCommand(recurringDonationId: recurringRuleCell.recurringDonationId!)
        do {
            SVProgressHUD.show()
            
            try mediater.sendAsync(request: command) { canceled in
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
                        let alert = UIAlertController(title: "SomethingWentWrong".localized, message: "Tis misgegaan", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        }))
                        self.present(alert, animated: true, completion:  {})
                    }
                }
            }
        } catch  {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "SomethingWentWrong".localized, message: "Tis misgegaan", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                }))
                self.present(alert, animated: true, completion:  {})
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recurringRules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RecurringRuleTableCell.self), for: indexPath) as! RecurringRuleTableCell
        
        var rule = self.recurringRules[indexPath.row]
        
        var collectGroupDetail: CollectGroupDetailModel
        do {
            let collectGroupDetailList: [CollectGroupDetailModel] = try mediater.send(request: GetCollectGroupsQuery())
            collectGroupDetail = collectGroupDetailList.first(where: { $0.namespace == rule.namespace })!
            rule.collectGroupName = collectGroupDetail.name
            rule.collectGroupType = collectGroupDetail.type
            rule.indexPath = indexPath
        } catch
        {
            print(error)
        }
        cell.viewModel = rule
        cell.delegate = self
        
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
        if selectedIndex == indexPath.row { return 143 } else { return 99 }
    }
    
}
