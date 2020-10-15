//
//  RecurringDonationTurnsOverviewController.swift
//  ios
//
//  Created by Jonas Brabant on 12/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//
import UIKit
import Foundation
import SwifCron

class RecurringDonationTurnsOverviewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    private var mediater: MediaterWithContextProtocol = Mediater.shared
    
    var recurringDonation: RecurringRuleViewModel?
    var donations: [RecurringDonationTurnViewModel] = []
    
    @IBOutlet weak var teeebelFjiew: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            if let recurringDonation = recurringDonation {
                let recurringDonationTurns: [Int] = try self.mediater.send(request: GetRecurringDonationTurnsQuery(id: recurringDonation.id))
                let donationDetails: [DonationResponseModel] = try self.mediater.send(request: GetDonationsByIdsQuery(ids: recurringDonationTurns))
                let pastTurns = try self.mediater.send(request: GetRecurringDonationPastTurnsQuery(details: donationDetails))
                donations.append(contentsOf: pastTurns)
                
                guard let lastDonation: DonationResponseModel = donationDetails.last else { return }
                let futureTurns: [RecurringDonationTurnViewModel] = try self.mediater.send(request: GetRecurringDonationFutureTurnsQuery(recurringDonation: recurringDonation, recurringDonationLastTurn: lastDonation, recurringDonationPastTurnsCount: recurringDonationTurns.count))
                donations.append(contentsOf: futureTurns)
                }
        } catch  {
            print(error)
        }
        
        teeebelFjiew.delegate = self
        teeebelFjiew.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return donations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RecurringDonationTurnTableCell.self), for: indexPath) as! RecurringDonationTurnTableCell
        
        let viewModel = donations[indexPath.row]
        cell.amount.text = "€\(viewModel.amount)"
        cell.date.text = viewModel.day
        cell.month.text = viewModel.month
        return cell
    }
    
    @IBAction override func backPressed(_ sender: Any) {
        super.backPressed(sender)
    }
}


extension RecurringDonationTurnsOverviewController {

}

