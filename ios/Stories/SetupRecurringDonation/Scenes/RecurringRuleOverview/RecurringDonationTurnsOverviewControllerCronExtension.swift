//
//  RecurringDonationTurnsOverviewControllerCronExtension.swift
//  ios
//
//  Created by Mike Pattyn on 17/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

extension RecurringDonationTurnsOverviewController {
    func getFinalRunDate(date: Date, cronDayOfMonth: Int) -> Date {
        var nextRunDate = date
        let daysInMonth = getDaysInMonth(month: nextRunDate.getMonth(), year: nextRunDate.getYear())
        if cronDayOfMonth <= daysInMonth {
            nextRunDate = createDateFrom(day: cronDayOfMonth, month: nextRunDate.getMonth(), year: nextRunDate.getYear())
        } else if cronDayOfMonth > daysInMonth {
            nextRunDate = createDateFrom(day: daysInMonth, month: nextRunDate.getMonth(), year: nextRunDate.getYear())
        }
        return nextRunDate
    }
    private func createDateFrom(day: Int, month: Int, year: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        return calendar.date(from: components)!
    }
    private func getDaysInMonth(month: Int, year: Int) -> Int {
        let calendar = Calendar.current
        var startComps = DateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year
        var endComps = DateComponents()
        endComps.day = 1
        endComps.month = month == 12 ? 1 : month + 1
        endComps.year = month == 12 ? year + 1 : year
        let startDate = calendar.date(from: startComps)!
        let endDate = calendar.date(from:endComps)!
        let diff = calendar.dateComponents([Calendar.Component.day], from: startDate, to: endDate)
        return diff.day!
    }

    func add7Days(date: Date) -> Date {
        var dateComponents = DateComponents()
        dateComponents.day = 7
        return Calendar.current.date(byAdding: dateComponents, to: date)!
    }
    
    func addMonths(date: Date, months: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = months
        return Calendar.current.date(byAdding: dateComponents, to: date)!
    }
    
    func getFrequencyFromCron(cronExpression: String) -> Frequency {
        let elements = cronExpression.split(separator: " ")
        let day = elements[2], month = elements[3], dayOfWeek = elements[4]
        var frequency: Frequency?
        if (dayOfWeek != "*") { frequency = .Weekly }
        else if (day != "*") {
            if (month == "*") { frequency = .Monthly }
            else if (month.contains("/3")) { frequency = .ThreeMonthly }
            else if (month.contains("/6")) { frequency = .SixMonthly }
            else { frequency = .Yearly }
        }
        return frequency!
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
}
