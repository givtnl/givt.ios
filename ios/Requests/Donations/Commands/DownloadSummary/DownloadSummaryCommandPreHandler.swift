//
//  DownloadSummaryCommandPreHandler.swift
//  ios
//
//  Created by Mike Pattyn on 15/12/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class DownloadSummaryCommandPreHandler : RequestPreProcessorProtocol {
    func handle<R>(request: R, completion: @escaping (R) throws -> Void) throws where R : RequestProtocol {
        let command = request as! DownloadSummaryCommand
        
        guard command.fromDate == "" && command.tillDate == "", let year = command.year else {
            try! completion(request)
            return
        }
        
        command.fromDate = getUTCDateForYear(year: year)
        command.tillDate = getUTCDateForYear(year: year + 1)
        try! completion(command as! R)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is DownloadSummaryCommand
    }
    
    fileprivate func getUTCDateForYear(year: Int) -> String {
        var componentsForYearlySummaryComponents = DateComponents()
        componentsForYearlySummaryComponents.day = 1
        componentsForYearlySummaryComponents.month = 1
        componentsForYearlySummaryComponents.year = year
        let date = Calendar.current.date(from: componentsForYearlySummaryComponents)!
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: date)
    }
}
