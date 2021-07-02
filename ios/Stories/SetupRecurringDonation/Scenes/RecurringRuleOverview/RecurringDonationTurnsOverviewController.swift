//
//  RecurringDonationTurnsOverviewController.swift
//  ios
//
//  Created by Jonas Brabant on 12/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//
import UIKit
import Foundation
import SVProgressHUD

class RecurringDonationTurnsOverviewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    //input variables
    var recurringDonationId: String!
    var comingFromNotification = false
    
    private var mediater: MediaterWithContextProtocol = Mediater.shared
    private var log = LogService.shared
    
    private var recurringDonation: RecurringRuleViewModel? = nil
    internal var donations: [RecurringDonationTurnViewModel] = []
    internal var donationsByYear: [Int: [RecurringDonationTurnViewModel]] = [:]
    internal var donationsByYearSorted: [Dictionary<Int, [RecurringDonationTurnViewModel]>.Element]? = nil
    
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
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.width)! , height: (self.navigationController?.navigationBar.frame.height)!))
        titleLabel.text = navBar.title
        titleLabel.font = UIFont(name: "Avenir-Heavy", size: 18)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.baselineAdjustment = .alignCenters
        navBar.titleView = titleLabel
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
            recurringDonation = try? mediater.send(request: GetRecurringDonationsQuery()).first(where: { (recurringDonation) -> Bool in
                recurringDonation.id == recurringDonationId
            })
            
            if let recurringDonation = recurringDonation {
                
                let cgName = try mediater.send(request: GetCollectGroupsQuery()).first(where: { $0.namespace == recurringDonation.namespace })!.name
                
                (navBar.titleView as! UILabel).text = cgName
                
                let recurringDonationTurns: [Int] = try self.mediater.send(request: GetRecurringDonationTurnsQuery(id: recurringDonation.id))
                var donationDetails: [DonationResponseModel] = []
                if recurringDonationTurns.count >= 1 {
                    donationDetails = try self.mediater.send(request: GetDonationsByIdsQuery(ids: recurringDonationTurns))
                    
                    let pastTurns = getPastTurns(donationDetails: donationDetails)
                    donations.append(contentsOf: pastTurns)
                }
                var lastDonationDate: Date
                
                var futureTurn: RecurringDonationTurnViewModel?
                
                if donationDetails.count < recurringDonation.endsAfterTurns {
                    if donationDetails.count >= 1 {
                        lastDonationDate = (donationDetails.last?.Timestamp.toDate!)!
                        futureTurn = getFutureTurn(recurringDonation: recurringDonation, recurringDonationLastDate: lastDonationDate, recurringDonationPastTurnsCount: recurringDonationTurns.count)
                    } else {
                        lastDonationDate = recurringDonation.startDate.toDate!.addingTimeInterval(-1)
                        futureTurn = getFutureTurn(recurringDonation: recurringDonation, recurringDonationLastDate: lastDonationDate, recurringDonationPastTurnsCount: recurringDonationTurns.count, isFirst: true)
                    }
                }
                donations = donations.reversed()
                
                donationsByYear = Dictionary(grouping: donations, by: {Int($0.year)!})
                
                if let futureTurn = futureTurn {
                    donationsByYear[9999] = [futureTurn]
                }
                
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
}


