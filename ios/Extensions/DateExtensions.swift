//
//  Date+helpers.swift
//  ios
//
//  Created by Lennie Stockman on 19/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation

extension Date {
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        guard date1 < date2 else { return false }
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
    
    public func getYear() -> Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: self)
    }
    
    public func getMonth() -> Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: self)
    }
    
    public func getDay() -> Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: self)
    }
    
    public func getHour() -> Int {
        let calendar = Calendar.current
        return calendar.component(.hour, from: self)
    }
    
    public func getMinutes() -> Int {
        let calendar = Calendar.current
        return calendar.component(.minute, from: self)
    }
    
    public func getSeconds() -> Int {
        let calendar = Calendar.current
        return calendar.component(.second, from: self)
    }
    
    public func getMonthName() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM"
        return fmt.monthSymbols[self.getMonth() - 1]
    }
    
    public func getMonthNameLong() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM"
        return fmt.monthSymbols[self.getMonth() - 1]
    }
    
    public func toString(_ format: String) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = format
        return fmt.string(from: self)
    }
    
    public func toISOString() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.locale = Locale(identifier: "en_US_POSIX")
        return df.string(from: self)
    }
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()
    static let formatterShort: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    static let yearAndMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()
    var formatted: String {
        return Date.formatter.string(from: self)
    }
    var formattedShort: String {
        return Date.formatterShort.string(from:self)
    }
    var formattedYearAndMonth: String {
        return Date.yearAndMonthFormatter.string(from: self)
    }
    var shortDate: Date {
        var dateComponents = DateComponents()
        dateComponents.day = self.getDay()
        dateComponents.month = self.getMonth()
        dateComponents.year = self.getYear()
        return Calendar.current.date(from: dateComponents)!
    }

    static var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }

    static var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }
    
    var nextMonth: Date {
        return Calendar.current.date(byAdding: .month, value: 1, to: self)!
    }
}
