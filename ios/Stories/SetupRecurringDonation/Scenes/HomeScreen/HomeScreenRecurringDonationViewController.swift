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
    
    @IBOutlet weak var RecurringDonationsRuleOverview: UIView!
    @IBOutlet var createButton: CreateRecurringDonationButton!
    @IBOutlet var recurringDonationsOverviewTitleLabel: UILabel!
    
    private var tempTableView: UITableView!
    private var mediater: MediaterWithContextProtocol = Mediater.shared
    
    var recurringRules:[RecurringRuleViewModel] = []
    var frequencies = ["SetupRecurringGiftWeek".localized, "SetupRecurringGiftMonth".localized, "SetupRecurringGiftQuarter".localized, "SetupRecurringGiftHalfYear".localized, "SetupRecurringGiftYear".localized]
    var selectedIndex: Int? = nil
    
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
        let rule = self.recurringRules[indexPath.row]
        var color: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        
        switch MediumHelper.namespaceToOrganisationType(namespace: rule.namespace) {
        case .church:
            cell.logoImageView.image = UIImage(imageLiteralResourceName: "church_white")
            color = ColorHelper.Church
        case .charity:
            cell.logoImageView.image = UIImage(imageLiteralResourceName: "stichting_white")
            color = ColorHelper.Charity
        case .campaign:
            cell.logoImageView.image = UIImage(imageLiteralResourceName: "actions_white")
            color = ColorHelper.Action
        case .artist:
            cell.logoImageView.image = UIImage(imageLiteralResourceName: "artist")
            color = ColorHelper.Artist
        default:
            break
        }
//        cell.viewModel = rule
        cell.nameLabel.text = GivtManager.shared.getOrganisationName(organisationNameSpace: rule.namespace)
        cell.cronTextLabel.text = "SetupRecurringGiftText_3".localized + " " + rule.getFrequencyFromCron() + " " + "RecurringDonationYouGive".localized + " " + UserDefaults.standard.currencySymbol + String(format: "%.2f", rule.amountPerTurn)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let endDate:String = formatter.string(from: rule.getEndDateFromRule())
        cell.endDateLabel.text = "RecurringDonationStops".localized.replacingOccurrences(of: "{0}", with: endDate)
        cell.logoContainerView.backgroundColor = color
        cell.stackViewRuleView.layer.borderColor = color.cgColor
        cell.stopLabel.text = "CancelSubscription".localized
        cell.stopLabel.textColor = ColorHelper.GivtRed
        cell.recurringDonationId = rule.id
        cell.rowIndexPath = indexPath
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
        if selectedIndex == indexPath.row { return 119 } else { return 89 }
    }
    
}
