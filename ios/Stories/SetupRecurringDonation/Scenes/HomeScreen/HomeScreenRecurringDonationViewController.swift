//
//  HomeScreenRecurringDonationViewController.swift
//  ios
//
//  Created by Jonas Brabant on 25/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import Foundation

class HomeScreenRecurringDonationViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet var navBar: UINavigationItem!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var emptyListLabel: UILabel!
    
    @IBOutlet weak var RecurringDonationsRuleOverview: UIView!
    @IBOutlet var createButton: CreateRecurringDonationButton!
    @IBOutlet var recurringDonationsOverviewTitleLabel: UILabel!
    
    private var mediater: MediaterWithContextProtocol = Mediater.shared
    
    var recurringRules:[RecurringRuleViewModel] = []
    var frequencies = ["SetupRecurringGiftWeek".localized, "SetupRecurringGiftMonth".localized, "SetupRecurringGiftQuarter".localized, "SetupRecurringGiftHalfYear".localized, "SetupRecurringGiftYear".localized]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = "TitleRecurringGifts".localized
        createButton.label1.text = "RecurringGiftsSetupCreate".localized
        createButton.label2.text = "RecurringGiftsSetupRecurringGift".localized
        recurringDonationsOverviewTitleLabel.text = "OverviewRecurringDonations".localized
        tableView.delegate = self
        tableView.dataSource = self
        RecurringDonationsRuleOverview.layer.cornerRadius = 8
    }
    override func viewWillAppear(_ animated: Bool) {
        do {
            recurringRules = try mediater.send(request: GetRecurringDonationsQuery())
            if recurringRules.count == 0 {
                tableView.removeFromSuperview()
                emptyListLabel.text = "EmptySubscriptionList".localized
            } else {
                if let view = imageView {
                    view.removeFromSuperview()
                }
                tableView.reloadData()
            }
        } catch  {
            tableView.removeFromSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recurringRules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RecurringRuleTableCell.self), for: indexPath) as! RecurringRuleTableCell
        let rule = self.recurringRules[indexPath.row]
        var color: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

        switch MediumHelper.namespaceToOrganisationType(namespace: rule.namespace) {
            case .church:
                cell.Logo.image = UIImage(imageLiteralResourceName: "church_white")
                color = #colorLiteral(red: 0.1843137255, green: 0.5058823529, blue: 0.7843137255, alpha: 1)
            case .charity:
                cell.Logo.image = UIImage(imageLiteralResourceName: "stichting_white")
                color = #colorLiteral(red: 0.9294117647, green: 0.6470588235, blue: 0.1803921569, alpha: 1)
            case .campaign:
                cell.Logo.image = UIImage(imageLiteralResourceName: "actions_white")
                color = #colorLiteral(red: 0.9460871816, green: 0.4409908056, blue: 0.3430213332, alpha: 1)
            case .artist:
                cell.Logo.image = UIImage(imageLiteralResourceName: "artist")
                color = #colorLiteral(red: 0.1137254902, green: 0.662745098, blue: 0.4235294118, alpha: 1)
            default:
                break
        }
        cell.Name.text = GivtManager.shared.getOrganisationName(organisationNameSpace: rule.namespace)
        let cron = frequencies[evaluateCronExpression(cronExpression: rule.cronExpression)]
        cell.Cron.text = "SetupRecurringGiftText_3".localized + " " + cron + " " + "RecurringDonationYouGive".localized + " " + UserDefaults.standard.currencySymbol + String(format: "%.2f", rule.amountPerTurn)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let endDate:String = formatter.string(from: evaluateEndDateFromSubscription(recurringRule: rule))
        cell.EndDate.text = "RecurringDonationStops".localized.replacingOccurrences(of: "{0}", with: endDate)
        cell.CenterView.layer.borderWidth = 1
        cell.CenterView.layer.cornerRadius = 8
        cell.Indication.isHidden = true
        cell.Logo.contentMode = .scaleAspectFill
        cell.LogoView.layer.cornerRadius = 4
        cell.LogoView.backgroundColor = color
        cell.CenterView.layer.borderColor = color.cgColor
        return cell
    }
    
    private func evaluateCronExpression(cronExpression: String) -> Int {
        let elements = cronExpression.split(separator: " ")
        let day = elements[2]
        let month = elements[3]
        let dayOfWeek = elements[4]
        var frequency: Int = 0
        if (dayOfWeek != "*") {
            frequency = 0
        }
        if (day != "*") {
            if (month == "*") {
                frequency = 1
            }
            if (month.contains("/3")) {
                frequency = 2
            }
            if (month.contains("/6")) {
                frequency = 3
            }
            if (month.contains("/12")) {
                frequency = 4
            }
        }
        return frequency
    }
    
    private func evaluateEndDateFromSubscription(recurringRule: RecurringRuleViewModel) -> Date {
        let multiplier = recurringRule.endsAfterTurns-1
        let startDate = Date(timeIntervalSince1970: TimeInterval(recurringRule.startDate * 1000) / 1000)
        var dateComponent = DateComponents()
        switch evaluateCronExpression(cronExpression: recurringRule.cronExpression) {
        case 0:
            dateComponent.weekOfYear = multiplier
        case 1:
            dateComponent.month = multiplier
        case 2:
            dateComponent.month = multiplier * 3
        case 3:
            dateComponent.month = multiplier * 6
        case 4:
            dateComponent.year = multiplier
        default:
            break
        }
        return Calendar.current.date(byAdding: dateComponent, to: startDate) as! Date
    }

    
    @IBAction func createRecurringDonationButtonTapped(_ sender: Any) {
        try? mediater.send(request: GoToChooseSubscriptionRoute(), withContext: self)
    }
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: BackToMainRoute(), withContext: self)
    }
}
