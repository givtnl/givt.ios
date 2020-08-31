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
    
    // Data model
    let animals: [String] = ["Horse", "Cow", "Camel", "Sheep", "Goat"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        RecurringDonationsRuleOverview.layer.cornerRadius = 8
        let recurringRules:[RecurringRuleViewModel]
        do {
            recurringRules = try mediater.send(request: GetSubscriptionsCommand())
        } catch  {
        }
        //
        //        }
        //        let resulaat:Bool = try mediater.send(request: GetSubscriptionsCommand(), withContext: self)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.animals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RecurringRuleTableCell.self), for: indexPath) as! RecurringRuleTableCell
        
        cell.Name.text = self.animals[indexPath.row]
        
        cell.CenterView.layer.borderWidth = 1
        cell.CenterView.layer.cornerRadius = 8
        cell.Indication.isHidden = true
        
        switch self.animals[indexPath.row] {
        case "Cow":
            cell.Logo = UIImageView(image: #imageLiteral(resourceName: "church_white"))
            cell.LogoView.backgroundColor = #colorLiteral(red: 0.1843137255, green: 0.5058823529, blue: 0.7843137255, alpha: 1)
            cell.CenterView.layer.borderColor = #colorLiteral(red: 0.1843137255, green: 0.5058823529, blue: 0.7843137255, alpha: 1)
            cell.LogoView.layer.cornerRadius = 4
        case "Camel":
            cell.Logo = UIImageView(image: #imageLiteral(resourceName: "stichting_white"))
            cell.LogoView.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.6470588235, blue: 0.1803921569, alpha: 1)
            cell.CenterView.layer.borderColor = #colorLiteral(red: 0.9294117647, green: 0.6470588235, blue: 0.1803921569, alpha: 1)
            cell.LogoView.layer.cornerRadius = 4
        case "Sheep":
            cell.Logo = UIImageView(image: #imageLiteral(resourceName: "actions_white"))
            cell.LogoView.backgroundColor = #colorLiteral(red: 0.9460871816, green: 0.4409908056, blue: 0.3430213332, alpha: 1)
            cell.CenterView.layer.borderColor = #colorLiteral(red: 0.9460871816, green: 0.4409908056, blue: 0.3430213332, alpha: 1)
            cell.LogoView.layer.cornerRadius = 4
        default:
            cell.Logo = UIImageView(image: #imageLiteral(resourceName: "artist"))
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
