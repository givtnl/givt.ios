//
//  ios_tests.swift
//  ios.tests
//
//  Created by Mike Pattyn on 22/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import XCTest
@testable import ios // this imports the entire ios app in to the tests workspace

class RecurringDonationCalculateLastTurnTests: XCTestCase {
    // MARK: Setup last recurring donation date and recurring donation
    var recurringDonation: RecurringRuleViewModel = RecurringRuleViewModel(
        namespace: "", collectGroupName: "", endsAfterTurns: 10, id: "", currentState: .Active,
        cronExpression: "", amountPerTurn: 0, startDate: "", collectGroupType: .artist, indexPath: nil)
    
    // MARK: Weekly cron test
    func testEnsureWeeklyRecurringDonationIsDoneSevenDaysLater() throws {
        let lastDonationDate = "2021-03-17T00:00:00.000Z"
        recurringDonation.cronExpression = "0 0 * * WED"
        
        let result = RecurringDonationTurnsOverviewController()
            .getFutureTurn(
                recurringDonation: recurringDonation,
                recurringDonationLastDate: (lastDonationDate.toDate)!,
                recurringDonationPastTurnsCount: 0
            )
        
        XCTAssertEqual(result.day, "24")
    }
    
    func testEnsureWeeklyRecurringDonationIsDoneSevenDaysLaterWhenTheMonthChanges() throws {
        let lastDonationDate = "2021-04-28T00:00:00.000Z"
        recurringDonation.cronExpression = "0 0 * * WED"
        
        let result = RecurringDonationTurnsOverviewController()
            .getFutureTurn(
                recurringDonation: recurringDonation,
                recurringDonationLastDate: (lastDonationDate.toDate)!,
                recurringDonationPastTurnsCount: 0
            )
        
        XCTAssertEqual(result.day, "5")
    }
    
    // MARK: Monthly cron test
    func testEnsureMonthlyRecurringDonationIsDoneOnTheLastDayOfTheMonthAndNotANewMonth() throws {
        let lastDonationDate = "2021-01-31T00:00:00.000Z"
        recurringDonation.cronExpression = "0 0 31 * *"
        
        let result = RecurringDonationTurnsOverviewController()
            .getFutureTurn(
                recurringDonation: recurringDonation,
                recurringDonationLastDate: (lastDonationDate.toDate)!,
                recurringDonationPastTurnsCount: 0
            )
        
        XCTAssertEqual(result.day, "28")
    }
    
    func testEnsureMonthlyRecurringDonationIsDoneOnTheLastDayOfTheMonthAndNotANewMonthSchrikkeljaar() throws {
        let lastDonationDate = "2024-01-31T00:00:00.000Z"
        recurringDonation.cronExpression = "0 0 31 * *"
        
        let result = RecurringDonationTurnsOverviewController()
            .getFutureTurn(
                recurringDonation: recurringDonation,
                recurringDonationLastDate: (lastDonationDate.toDate)!,
                recurringDonationPastTurnsCount: 0
            )
        
        XCTAssertEqual(result.day, "29")
    }
    
    // MARK: Three monthly cron test
    func testEnsureThreeMonthlyRecurringDonationIsDoneOnTheLastDayOfTheMonthAndNotANewMonth() throws {
        let lastDonationDate = "2020-11-30T00:00:00.000Z"
        recurringDonation.cronExpression = "0 0 30 11/3 *"
        
        let result = RecurringDonationTurnsOverviewController()
            .getFutureTurn(
                recurringDonation: recurringDonation,
                recurringDonationLastDate: (lastDonationDate.toDate)!,
                recurringDonationPastTurnsCount: 0
            )
        
        XCTAssertEqual(result.day, "28")
    }
    
    // MARK: Yearly cron test
    func testEnsureYearlyRecurringDonationIsDoneOnTheLastDayOfTheMonthAndNotANewMonth() throws {
        let lastDonationDate = "2024-02-29T00:00:00.000Z"
        recurringDonation.cronExpression = "0 0 29 2/12 *"
        
        let result = RecurringDonationTurnsOverviewController()
            .getFutureTurn(
                recurringDonation: recurringDonation,
                recurringDonationLastDate: (lastDonationDate.toDate)!,
                recurringDonationPastTurnsCount: 0
            )
        
        XCTAssertEqual(result.day, "28")
    }
}
