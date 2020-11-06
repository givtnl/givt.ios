//
//  RecurringDonationTurnsOverviewControllerExension.swift
//  ios
//
//  Created by Mike Pattyn on 20/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import SwifCron

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
    
    private func createSwifCron(cronString: String) -> SwifCron? {
        do {
            let cronItems: [String] = transformDayInCronToInt(cronArray: cronString.components(separatedBy: " "))
            return try SwifCron(cronItems.joined(separator: " "))
        }
        catch {
            return nil
        }
    }
    private func transformDayInCronToInt(cronArray: [String]) -> [String] {
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
            day = "0"
        default:
            day = "*"
        }
        newarray[4] = day
        return newarray
    }
    
    func setupInfoViewContainer() {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return donationsByYearSorted![section].value.count
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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel()
        title.textColor = UIColor.red
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.font = title.font
        header.textLabel!.textColor = title.textColor
        header.contentView.backgroundColor = UIColor.white
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header_cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableSectionHeaderRecurringRuleOverviewView") as! TableSectionHeaderRecurringRuleOverview
        
        header_cell.opaqueLayer.isHidden = true
        
        let giftsFromSameYear = donationsByYearSorted![section]
        let giftsFromSameYear_First = giftsFromSameYear.value.first
        let year : Int = Int(giftsFromSameYear_First!.year)!
        
        if(giftsFromSameYear.key == 9999 && giftsFromSameYear_First!.toBePlanned) {
        
            if(donationsByYearSorted![section].value.count > 0) {
                if (donationsByYearSorted!.count == 1) {
                    header_cell.year.text = "RecurringDonationFutureDetailDifferentYear".localized + " " + String(year)
                }
                else if(donationsByYearSorted!.count > 1) {
                    let nextYear = donationsByYearSorted![section+1].key
                    if (nextYear == year) {
                        header_cell.year.text = "RecurringDonationFutureDetailSameYear".localized
                    } else {
                        header_cell.year.text = "RecurringDonationFutureDetailDifferentYear".localized + " " + String(year)
                    }
                }
            }
            else {
                header_cell.isHidden = true
            }
        }
        else {
            header_cell.year.text = "\(year)"
        }
        
        return header_cell
    }

}

