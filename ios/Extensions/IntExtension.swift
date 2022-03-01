//
//  IntExtension.swift
//  ios
//
//  Created by Mike Pattyn on 28/09/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
extension Int {
    var decimal: Decimal {
        return Decimal(self)
    }
    var string: String {
        return String(self)
    }
    var double: Double {
        return Double(self)
    }
    
    
    
    func getUTCDateForYear(type: DateType) -> String {
        var componentsForYearlySummaryComponents = DateComponents()
        componentsForYearlySummaryComponents.day = 1
        componentsForYearlySummaryComponents.month = 1
        componentsForYearlySummaryComponents.year = [DateType.start: self, DateType.end: self+1][type]
        let date = Calendar.current.date(from: componentsForYearlySummaryComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}
