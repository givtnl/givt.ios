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
    @IBOutlet var givyContainer: UIView!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "TableSectionHeaderRecurringRuleOverviewView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "TableSectionHeaderRecurringRuleOverviewView")

        givyContainer.isHidden = false

        do {
            if let recurringDonation = recurringDonation {
                
                let recurringDonationTurns: [Int] = try self.mediater.send(request: GetRecurringDonationTurnsQuery(id: recurringDonation.id))
                let donationDetails: [DonationResponseModel] = try self.mediater.send(request: GetDonationsByIdsQuery(ids: recurringDonationTurns))

                let pastTurns = getPastTurns(donationDetails: donationDetails)
                donations.append(contentsOf: pastTurns)
                
                guard let lastDonation: DonationResponseModel = donationDetails.last else { return }
                let futureTurns: [RecurringDonationTurnViewModel] = getFutureTurns(recurringDonation: recurringDonation, recurringDonationLastTurn: lastDonation, recurringDonationPastTurnsCount: recurringDonationTurns.count, maxCount: 5)
                
                donations.append(contentsOf: futureTurns)
            }
        } catch {
            print(error)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RecurringDonationTurnTableCell.self), for: indexPath) as! RecurringDonationTurnTableCell
        
        let viewModel = donations[indexPath.row]
        cell.amount.text = "€\(viewModel.amount)"
        cell.date.text = viewModel.day
        cell.month.text = viewModel.month
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Dequeue with the reuse identifier
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableSectionHeaderRecurringRuleOverviewView")
        let header = cell as! TableSectionHeaderRecurringRuleOverview
        header.year.text = "Yey"
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return donations.count
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
    @IBAction override func backPressed(_ sender: Any) {
        try? mediater.send(request: BackToRecurringDonationOverviewRoute(), withContext: self)
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
            let model = RecurringDonationTurnViewModel(amount: currentAmount, day: currentDay, month: currentMonth, year: currentYear, status: currentStatus)
            donations.append(model)
        }
        return donations
    }
    func getFutureTurns(recurringDonation: RecurringRuleViewModel, recurringDonationLastTurn: DonationResponseModel, recurringDonationPastTurnsCount: Int, maxCount: Int)  -> [RecurringDonationTurnViewModel] {
        var donations: [RecurringDonationTurnViewModel] = []

        do {

            guard let lastDonationDate: Date = recurringDonationLastTurn.Timestamp.toDate else {
                return []
            }
            guard let cronObject: SwifCron = createSwifCron(cronString: recurringDonation.cronExpression) else {
                return []
            }
            
            var nextRunDate = try cronObject.next(from: lastDonationDate)
            
            let currentDay: String = nextRunDate.getDay().string
            let currentMonth: String = nextRunDate.getMonthName()
            let currentYear: String = nextRunDate.getYear().string
            
            let model = RecurringDonationTurnViewModel(amount: Decimal(recurringDonation.amountPerTurn), day: currentDay, month: currentMonth, year: currentYear, status: 0)
            
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
                    
                    let model = RecurringDonationTurnViewModel(amount: Decimal(recurringDonation.amountPerTurn), day: currentDay, month: currentMonth, year: currentYear, status: 0)
                    
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

