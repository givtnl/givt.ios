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
    private var mediater: MediaterWithContextProtocol = Mediater.shared
    
    var recurringDonationId: String?
    var donations: [RecurringDonationDonationViewModel]?
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "RecurringRuleOverviewCell", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "recurringRuleOverviewCell")
        
        do {
            self.donations = try self.mediater.send(request: GetDonationsFromRecurringDonationQuery(id: recurringDonationId!))
        } catch  {
            print("ERROR: GOESTING NOT FOUND")
        }
        
        print(self.donations)
    }
}
