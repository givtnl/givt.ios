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
import SVProgressHUD

class RecurringDonationTurnsOverviewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    private var mediater: MediaterWithContextProtocol = Mediater.shared
    private var log = LogService.shared
    
    var recurringDonation: RecurringRuleViewModel?
    var donations: [RecurringDonationTurnViewModel] = []
    var donationsByYear: [Int: [RecurringDonationTurnViewModel]] = [:]
    var donationsByYearSorted: [Dictionary<Int, [RecurringDonationTurnViewModel]>.Element]? = nil
    
    @IBOutlet var givyContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var givyContainer_label: UILabel!
    @IBOutlet weak var legendOverlay: InfoViewRecurringRuleOverview!
    @IBOutlet weak var legendOverlayHeight: NSLayoutConstraint!
    @IBOutlet weak var navBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set table
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "TableSectionHeaderRecurringRuleOverviewView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "TableSectionHeaderRecurringRuleOverviewView")
        tableView.tableFooterView = UIView()
        
        // Make Givy visible and hide table
        givyContainer.isHidden = true
        
        // Set title
        navBar.title = "TitleRecurringGifts".localized
        
        setupInfoViewContainer()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.isHidden = true
        givyContainer.isHidden = false
        givyContainer_label.text = "LoadingMessage".localized
        
        SVProgressHUD.show()
    }
    override func viewDidAppear(_ animated: Bool) {
        
        do {
            if let recurringDonation = recurringDonation {
                navBar.title = recurringDonation.collectGroupName
                
                let recurringDonationTurns: [Int] = try self.mediater.send(request: GetRecurringDonationTurnsQuery(id: recurringDonation.id))
                var donationDetails: [DonationResponseModel] = []
                if recurringDonationTurns.count >= 1 {
                    donationDetails = try self.mediater.send(request: GetDonationsByIdsQuery(ids: recurringDonationTurns))
                    
                    let pastTurns = getPastTurns(donationDetails: donationDetails)
                    donations.append(contentsOf: pastTurns)
                }
                var lastDonationDate: Date
                
                if donationDetails.count >= 1 {
                    lastDonationDate = (donationDetails.last?.Timestamp.toDate!)!
                } else {
                    lastDonationDate = recurringDonation.startDate.toDate!
                }
                
                let futureTurns: [RecurringDonationTurnViewModel] = getFutureTurns(recurringDonation: recurringDonation, recurringDonationLastDate: lastDonationDate, recurringDonationPastTurnsCount: recurringDonationTurns.count, maxCount: 1)
                
                //                donations.append(contentsOf: futureTurns)
                
                donations = donations.reversed()
                
                donationsByYear = Dictionary(grouping: donations, by: {Int($0.year)!})
                
                donationsByYear[9999] = futureTurns
                
                donationsByYearSorted = donationsByYear.sorted { (first, second) -> Bool in
                    return first.key > second.key
                }
            }
            
            self.tableView.isHidden = false
            givyContainer.isHidden = true
            
            tableView.reloadData()
            
        } catch {
            log.warning(message: "Recurring donation was not found or nil, this shouldnt happen")
            
            self.tableView.isHidden = true
            givyContainer.isHidden = false
            givyContainer_label.text = "SomethingWentWrong".localized
        }
        SVProgressHUD.dismiss()
    }
    
    @IBAction override func backPressed(_ sender: Any) {
        try? mediater.send(request: BackToRecurringDonationOverviewRoute(), withContext: self)
    }
    @IBAction func openInfo(_ sender: Any) {
        UIView.animate(withDuration: 1, animations: {
            self.legendOverlay.frame.origin.y = 0
            self.navigationController?.navigationBar.isHidden = true
            self.view.layoutIfNeeded()
        })
    }
    @objc func closeInfo() {
        UIView.animate(withDuration: 1, animations: {
            self.legendOverlay.frame.origin.y = -340
            self.navigationController?.navigationBar.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
}


