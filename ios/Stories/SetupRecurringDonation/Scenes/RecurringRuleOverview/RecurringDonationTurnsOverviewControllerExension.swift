//
//  RecurringDonationTurnsOverviewControllerExension.swift
//  ios
//
//  Created by Mike Pattyn on 20/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

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
    func getFutureTurn(recurringDonation: RecurringRuleViewModel, recurringDonationLastDate: Date, recurringDonationPastTurnsCount: Int, isFirst: Bool = false)  -> RecurringDonationTurnViewModel {
        let lastDonationDate: Date = recurringDonationLastDate

        var nextRunDate: Date? = nil
        
        if isFirst {
            let currentDay: String = recurringDonationLastDate.getDay().string
            let currentMonth: String = recurringDonationLastDate.getMonthName()
            let currentYear: String = recurringDonationLastDate.getYear().string
            return RecurringDonationTurnViewModel(amount: Decimal(recurringDonation.amountPerTurn), day: currentDay, month: currentMonth, year: currentYear, status: 0, toBePlanned: true)
        } else {
            let cronDayOfMonth = Int(recurringDonation.cronExpression.split(separator: " ")[2])!

            switch getFrequencyFromCron(cronExpression: recurringDonation.cronExpression) {
                case .Weekly:
                    nextRunDate = add7Days(date: lastDonationDate)
                case .Monthly:
                    nextRunDate = getFinalRunDate(date: addMonths(date: lastDonationDate, months: 1), cronDayOfMonth: cronDayOfMonth)
                case .ThreeMonthly:
                    nextRunDate = getFinalRunDate(date: addMonths(date: lastDonationDate, months: 3), cronDayOfMonth: cronDayOfMonth)
                case .SixMonthly:
                    nextRunDate = getFinalRunDate(date: addMonths(date: lastDonationDate, months: 6), cronDayOfMonth: cronDayOfMonth)
                case .Yearly:
                    nextRunDate = getFinalRunDate(date: addMonths(date: lastDonationDate, months: 12), cronDayOfMonth: cronDayOfMonth)
            }
            
            let currentDay: String = nextRunDate!.getDay().string
            let currentMonth: String = nextRunDate!.getMonthName()
            let currentYear: String = nextRunDate!.getYear().string
            
            return RecurringDonationTurnViewModel(amount: Decimal(recurringDonation.amountPerTurn), day: currentDay, month: currentMonth, year: currentYear, status: 0, toBePlanned: true)
        }
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

