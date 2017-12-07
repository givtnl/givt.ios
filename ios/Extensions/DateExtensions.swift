//
//  Date+helpers.swift
//  ios
//
//  Created by Lennie Stockman on 19/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation

extension Date {
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
    
    public func toString(_ format: String) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = format
        return fmt.string(from: self)
    }
}
