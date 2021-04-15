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
            
            var cronDay: Int? = nil
            
            if let cronDayOfMonth = Int(recurringDonation.cronExpression.split(separator: " ")[2]) {
                cronDay = cronDayOfMonth
            }

            switch getFrequencyFromCron(cronExpression: recurringDonation.cronExpression) {
                case .Weekly:
                    nextRunDate = add7Days(date: lastDonationDate)
                case .Monthly:
                    nextRunDate = getFinalRunDate(date: addMonths(date: lastDonationDate, months: 1), cronDayOfMonth: cronDay!)
                case .ThreeMonthly:
                    nextRunDate = getFinalRunDate(date: addMonths(date: lastDonationDate, months: 3), cronDayOfMonth: cronDay!)
                case .SixMonthly:
                    nextRunDate = getFinalRunDate(date: addMonths(date: lastDonationDate, months: 6), cronDayOfMonth: cronDay!)
                case .Yearly:
                    nextRunDate = getFinalRunDate(date: addMonths(date: lastDonationDate, months: 12), cronDayOfMonth: cronDay!)
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
}

