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
    fileprivate func setupInfoViewContainer() {
        // adding gesture recognizers manually because in teh close method we are accessing the nav controller
        // cannot access nav controller from xib swift context
        
        // add swipe gesture so users can swipe up to close the view
        let swipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(closeInfo))
        swipeGesture.direction = UISwipeGestureRecognizer.Direction.up
        legendOverlay.addGestureRecognizer(swipeGesture)
        
        // add tap gesture recognizer to image and its parent view
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeInfo))
        legendOverlay.closeInfoView.addGestureRecognizer(tapGesture)
        legendOverlay.closeInfoViewImage.addGestureRecognizer(tapGesture)

        // put the view inside the navbar
        legendOverlay.removeFromSuperview()
        self.navigationController!.view.addSubview(legendOverlay)
        
        legendOverlay.contentView.leadingAnchor.constraint(equalTo: (self.navigationController?.view.leadingAnchor)!).isActive = true
        legendOverlay.contentView.trailingAnchor.constraint(equalTo: (self.navigationController?.view.trailingAnchor)!).isActive = true
        
        if UserDefaults.standard.accountType != AccountType.bacs {
            legendOverlayHeight.constant = 290
            legendOverlay.contentView.topAnchor.constraint(equalTo: (self.navigationController?.view.topAnchor)!, constant: -290).isActive = true
        } else {
            legendOverlayHeight.constant = 340
            legendOverlay.contentView.topAnchor.constraint(equalTo: (self.navigationController?.view.topAnchor)!, constant: -340).isActive = true
        }
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RecurringDonationTurnTableCell.self), for: indexPath) as! RecurringDonationTurnTableCell
        
        cell.viewModel = donationsByYearSorted![indexPath.section].value[indexPath.row]
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(donationsByYearSorted != nil) {
            return donationsByYearSorted!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return donationsByYearSorted![section].value.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    //
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel()
        title.textColor = UIColor.red
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.font = title.font
        header.textLabel!.textColor = title.textColor
        header.contentView.backgroundColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Dequeue with the reuse identifier
        let yearText = donationsByYearSorted![section].key
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableSectionHeaderRecurringRuleOverviewView")
        let header = cell as! TableSectionHeaderRecurringRuleOverview
        
        header.opaqueLayer.isHidden = true
        
        if(donationsByYearSorted![section].key == 9999) {
            
            let yearNextDonation = Int(donationsByYearSorted![section].value[0].year)
            var yearLastDonation = yearNextDonation! - 1
            
            if (donationsByYearSorted!.count >= 2) {
                yearLastDonation = Int(donationsByYearSorted![1].value[0].year)!
            }
            
            if(yearNextDonation! > yearLastDonation) {
                header.year.text = "RecurringDonationFutureDetailDifferentYear".localized + " " + String(yearNextDonation!)
            }
            else {
                header.year.text = "RecurringDonationFutureDetailSameYear".localized
            }
            
        } else {
            header.year.text = "\(yearText)"
        }
        
        return cell
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
    func closeInfoView() {
        closeInfo()
    }
}


extension RecurringDonationTurnsOverviewController {
    func getPastTurns(donationDetails: [DonationResponseModel]) -> [RecurringDonationTurnViewModel] {
        var donations: [RecurringDonationTurnViewModel] = []
        for donationDetail in donationDetails {
            let currentDay: String = donationDetail.Timestamp.toDate!.getDay().string
            let currentMonth: String = donationDetail.Timestamp.toDate!.getMonthName()
            let currentYear: String = donationDetail.Timestamp.toDate!.getYear().string
            let currentAmount = donationDetail.Amount
            let currentStatus = donationDetail.Status
            let currentGiftAidEnabled = donationDetail.GiftAidEnabled
            let model = RecurringDonationTurnViewModel(amount: currentAmount, day: currentDay, month: currentMonth, year: currentYear, status: currentStatus, toBePlanned: false, isGiftAided: currentGiftAidEnabled)
            donations.append(model)
        }
        return donations
    }
    func getFutureTurns(recurringDonation: RecurringRuleViewModel, recurringDonationLastDate: Date, recurringDonationPastTurnsCount: Int, maxCount: Int)  -> [RecurringDonationTurnViewModel] {
        var donations: [RecurringDonationTurnViewModel] = []
        
        do {
            
            guard let lastDonationDate: Date = recurringDonationLastDate else {
                return []
            }
            guard let cronObject: SwifCron = createSwifCron(cronString: recurringDonation.cronExpression) else {
                return []
            }
            
            var nextRunDate = try cronObject.next(from: lastDonationDate)
            
            let currentDay: String = nextRunDate.getDay().string
            let currentMonth: String = nextRunDate.getMonthName()
            let currentYear: String = nextRunDate.getYear().string
            
            let model = RecurringDonationTurnViewModel(amount: Decimal(recurringDonation.amountPerTurn), day: currentDay, month: currentMonth, year: currentYear, status: 0, toBePlanned: true)
            
            donations.append(model)
            
            print(nextRunDate)
            
            let turnsToCalculate = recurringDonation.endsAfterTurns-recurringDonationPastTurnsCount
            
            if turnsToCalculate > 1 {
                for _ in 1...turnsToCalculate - 1 {
                    let prevRunDate = nextRunDate
                    
                    nextRunDate = try cronObject.next(from: prevRunDate)
                    
                    let currentDay: String = nextRunDate.getDay().string
                    let currentMonth: String = nextRunDate.getMonthName()
                    let currentYear: String = nextRunDate.getYear().string
                    
                    let model = RecurringDonationTurnViewModel(amount: Decimal(recurringDonation.amountPerTurn), day: currentDay, month: currentMonth, year: currentYear, status: 0, toBePlanned: true)
                    
                    donations.append(model)
                    
                    print(nextRunDate)
                }
            }
        } catch {
            print(error)
        }
        
        if donations.count > maxCount {
            donations = Array(donations.prefix(maxCount))
        }
        return donations
    }
    fileprivate func createSwifCron(cronString: String) -> SwifCron? {
        do {
            let cronItems: [String] = transformDayInCronToInt(cronArray: cronString.split(separator: " ").map(String.init))
            return try SwifCron(cronItems.joined(separator: " "))
        }
        catch {
            return nil
        }
    }
    
    fileprivate func transformDayInCronToInt(cronArray: [String]) -> [String] {
        var newarray = cronArray
        var day = newarray[4]
        switch day {
        case "MON":
            day = "1"
        case "TUE":
            day = "2"
        case "WED":
            day = "3"
        case "THU":
            day = "4"
        case "FRI":
            day = "5"
        case "SAT":
            day = "6"
        case "SUN":
            day = "7"
        default:
            day = "*"
        }
        newarray[4] = day
        return newarray
    }
    fileprivate func returnStringFromDayInteger(value: Int) -> String {
        var retVal: String
        switch value {
        case 1:
            retVal = "SUN"
        case 2:
            retVal = "MON"
        case 3:
            retVal = "TUE"
        case 4:
            retVal = "WED"
        case 5:
            retVal = "THU"
        case 6:
            retVal = "FRI"
        case 7:
            retVal = "SAT"
        default:
            retVal = "*"
        }
        return retVal
    }
}

