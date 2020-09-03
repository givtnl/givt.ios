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
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var RecurringDonationsRuleOverview: UIView!
    @IBOutlet var createButton: CreateRecurringDonationButton!
    @IBOutlet var recurringDonationsOverviewTitleLabel: UILabel!
    
    private var tempTableView: UITableView!
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
                tempTableView = tableView
                tableView.removeFromSuperview()
                emptyListLabel.text = "EmptySubscriptionList".localized
            } else {
                if let view = imageView {
                    view.removeFromSuperview()
                }
                if let table = tempTableView {
                    tableView = table
                }
                tableView.reloadData()
                stackView.addArrangedSubview(tableView)
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
                color = ColorHelper.Church
            case .charity:
                cell.Logo.image = UIImage(imageLiteralResourceName: "stichting_white")
                color = ColorHelper.Charity
            case .campaign:
                cell.Logo.image = UIImage(imageLiteralResourceName: "actions_white")
                color = ColorHelper.Action
            case .artist:
                cell.Logo.image = UIImage(imageLiteralResourceName: "artist")
                color = ColorHelper.Artist
            default:
                break
        }
        cell.Name.text = GivtManager.shared.getOrganisationName(organisationNameSpace: rule.namespace)
        let cron = frequencies[evaluateCronExpression(cronExpression: rule.cronExpression)]
        cell.Cron.text = "SetupRecurringGiftText_3".localized + " " + cron + " " + "RecurringDonationYouGive".localized + " " + UserDefaults.standard.currencySymbol + String(format: "%.2f", rule.amountPerTurn)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let endDate:String = formatter.string(from: evaluateEndDateFromRecurringDonation(recurringRule: rule))
        cell.EndDate.text = "RecurringDonationStops".localized.replacingOccurrences(of: "{0}", with: endDate)
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
    
    private func evaluateEndDateFromRecurringDonation(recurringRule: RecurringRuleViewModel) -> Date {
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
        try? mediater.send(request: GoToChooseRecurringDonationRoute(), withContext: self)
    }
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: BackToMainRoute(), withContext: self)
    }
}
