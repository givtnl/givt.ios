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
        
        command.fromDate = getStartDate(year: year)
        command.tillDate = getEndDate(year: year)
        try! completion(command as! R)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is DownloadSummaryCommand
    }
    
    fileprivate func getDateForYearlyOverview(dateComponents: DateComponents) -> String {
        let date = Calendar.current.date(from: dateComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    fileprivate func getStartDate(year: Int) -> String {
        var dateComponents = DateComponents()
        dateComponents.day = 1
        dateComponents.month = 1
        dateComponents.year = year
        return getDateForYearlyOverview(dateComponents: dateComponents)
    }
    
    fileprivate func getEndDate(year: Int) -> String {
        var dateComponents = DateComponents()
        dateComponents.day = 31
        dateComponents.month = 12
        dateComponents.year = year
        return getDateForYearlyOverview(dateComponents: dateComponents)
    }
}
