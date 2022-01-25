//
//  SetupRecurringDonationOverviewViewControllerExtension.swift
//  ios
//
//  Created by Mike Pattyn on 23/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import AppCenterAnalytics
import Mixpanel
import SVProgressHUD

extension SetupRecurringDonationOverviewViewController: RecurringRuleCancelDelegate, RecurringRuleListDelegate {    
    func recurringRuleCancelTapped(recurringRuleCell: RecurringRuleTableCell) {
        Analytics.trackEvent("RECURRING_DONATIONS_DONATION_STOP")
        Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_DONATION_STOP")
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "CancelRecurringDonationAlertTitle".localized.replacingOccurrences(of: "{0}", with: recurringRuleCell.nameLabel.text!), message: "CancelRecurringDonationAlertMessage".localized , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes".localized, style: .default, handler: { (action) in
                Analytics.trackEvent("RECURRING_DONATIONS_DONATION_STOP_YES")
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
                Analytics.trackEvent("RECURRING_DONATIONS_DONATION_STOP_NO")
                Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_DONATION_STOP_NO")
            }))
            self.present(alert, animated: true, completion:  {})
        }
    }
    
    func recurringRuleListTapped(recurringRuleCell: RecurringRuleTableCell) {
        if !AppServices.shared.isServerReachable {
            try? mediater.send(request: NoInternetAlert(), withContext: self)
        } else {
            try? mediater.send(request: OpenRecurringDonationOverviewListRoute(recurringDonationId: (recurringRuleCell.viewModel?.id)!), withContext: self)

        }
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
            Analytics.trackEvent("RECURRING_DONATIONS_DONATION_OPENED")
            Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_DONATION_OPENED")
            return 133
        } else {
            return 89
        }
    }
    func resetSelectedIndex() {
        selectedIndex = nil
    }
}
