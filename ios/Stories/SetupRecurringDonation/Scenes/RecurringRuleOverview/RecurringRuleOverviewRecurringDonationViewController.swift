//
//  RecurringRuleOverviewRecurringDonationViewController.swift
//  ios
//
//  Created by Jonas Brabant on 12/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class RecurringRuleOverviewRecurringDonationViewController : UIViewController
{
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "RecurringRuleOverviewCell", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "recurringRuleOverviewCell")
    }
}
