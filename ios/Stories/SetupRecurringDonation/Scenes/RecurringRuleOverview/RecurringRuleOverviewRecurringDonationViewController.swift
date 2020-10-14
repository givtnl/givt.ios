//
//  RecurringRuleOverviewRecurringDonationViewController.swift
//  ios
//
//  Created by Jonas Brabant on 12/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import SVProgressHUD
import UIKit

class RecurringRuleOverviewRecurringDonationViewController : UIViewController
{
    var recurringDonationId: String?
    var donations: [RecurringDonationDonationViewModel] = []
    public var reloadData: Bool = true;
    private var mediater: MediaterWithContextProtocol = Mediater.shared
    
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = "TitleRecurringGifts".localized
//        tableView.delegate = self
//        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.isHidden = true
        SVProgressHUD.show()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        do {
            self.donations = try self.mediater.send(request: GetDonationsFromRecurringDonationQuery(id: recurringDonationId!))
        } catch  {
            print("ERROR: GOESTING NOT FOUND")
        }
        self.tableView.reloadData()
        SVProgressHUD.dismiss()
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: BackToRecurringDonationOverviewRoute(), withContext: self)
    }
}
