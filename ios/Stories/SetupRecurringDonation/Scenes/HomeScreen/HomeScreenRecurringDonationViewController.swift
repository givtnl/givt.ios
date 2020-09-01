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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var RecurringDonationsRuleOverview: UIView!
    
    private var mediater: MediaterWithContextProtocol = Mediater.shared
    
    var recurringRules:[RecurringRuleViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        RecurringDonationsRuleOverview.layer.cornerRadius = 8
        
        do {
            recurringRules = try mediater.send(request: GetSubscriptionsCommand())
            self.tableView.reloadData()
        } catch  {
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recurringRules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RecurringRuleTableCell.self), for: indexPath) as! RecurringRuleTableCell
        
        let rule = self.recurringRules[indexPath.row]
        
        cell.Name.text = rule.nameSpace
        cell.Cron.text = rule.cronExpression
        cell.EndDate.text = String(rule.endsAfterTurns)
        
        cell.CenterView.layer.borderWidth = 1
        cell.CenterView.layer.cornerRadius = 8
        cell.Indication.isHidden = true
        
        switch rule.nameSpace {
        case "Cow":
            cell.Logo.image = UIImage(imageLiteralResourceName: "church_white")
            cell.Logo.contentMode = .scaleAspectFill
            cell.LogoView.backgroundColor = #colorLiteral(red: 0.1843137255, green: 0.5058823529, blue: 0.7843137255, alpha: 1)
            cell.CenterView.layer.borderColor = #colorLiteral(red: 0.1843137255, green: 0.5058823529, blue: 0.7843137255, alpha: 1)
            cell.LogoView.layer.cornerRadius = 4
        case "Camel":
            cell.Logo.image = UIImage(imageLiteralResourceName: "stichting_white")
            cell.Logo.contentMode = .scaleAspectFill
            cell.LogoView.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.6470588235, blue: 0.1803921569, alpha: 1)
            cell.CenterView.layer.borderColor = #colorLiteral(red: 0.9294117647, green: 0.6470588235, blue: 0.1803921569, alpha: 1)
            cell.LogoView.layer.cornerRadius = 4
        case "Sheep":
            cell.Logo.image = UIImage(imageLiteralResourceName: "actions_white")
            cell.Logo.contentMode = .scaleAspectFill
            cell.LogoView.backgroundColor = #colorLiteral(red: 0.9460871816, green: 0.4409908056, blue: 0.3430213332, alpha: 1)
            cell.CenterView.layer.borderColor = #colorLiteral(red: 0.9460871816, green: 0.4409908056, blue: 0.3430213332, alpha: 1)
            cell.LogoView.layer.cornerRadius = 4
        default:
            cell.Logo.image = UIImage(imageLiteralResourceName: "artist")
            cell.Logo.contentMode = .scaleAspectFill
            cell.LogoView.backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.662745098, blue: 0.4235294118, alpha: 1)
            cell.CenterView.layer.borderColor = #colorLiteral(red: 0.1137254902, green: 0.662745098, blue: 0.4235294118, alpha: 1)
            cell.LogoView.layer.cornerRadius = 4
        }
        return cell
    }
    
    @IBAction func createRecurringDonationButtonTapped(_ sender: Any) {
        try? mediater.send(request: GoToChooseSubscriptionRoute(), withContext: self)
    }
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: BackToMainRoute(), withContext: self)
    }
}
