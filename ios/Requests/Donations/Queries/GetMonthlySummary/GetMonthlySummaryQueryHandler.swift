//
//  GetMonthlySummaryQueryHandler.swift
//  ios
//
//  Created by Mike Pattyn on 23/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class GetMonthlySummaryQueryHandler: RequestHandlerProtocol {
    private var client = APIClient.shared

    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        let daysInMonth = getDaysInMonth(month: Int(currentMonth), year: Int(currentYear))!

        let fromDate = makeFromDateString(year: currentYear, month: currentMonth, day: 1)
        let tillDate = makeTillDateString(year: currentYear, month: currentMonth, day: daysInMonth)
        
        let route: String = "/api/v2/users/\(String(describing: UserDefaults.standard.userExt!.guid))/summary?groupType=0&fromDate=\(fromDate)&tillDate=\(tillDate)"
        
        client.get(url: route, data: [:]) { (response) in
            var models: [MonthlySummaryDetailModel] = []
            if let response = response, response.isSuccess {
                if let body = response.text {
                    do {
                        let decoder = JSONDecoder()
                        models = try decoder.decode([MonthlySummaryDetailModel].self, from: Data(body.utf8))
                    } catch {
                        print("\(error)")
                    }
                    try? completion(models as! R.TResponse)
                }
            } else {
                try? completion(models as! R.TResponse)
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GetMonthlySummaryQuery
    }
    func getDaysInMonth(month: Int, year: Int) -> Int? {
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
        
        return diff.day
    }
    
    func makeFromDateString(year: Int, month: Int, day: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let calendar = Calendar(identifier: .gregorian)
        
        let components = DateComponents(year: year, month: month, day: day)
        
        let tilDate = calendar.date(from: components)!
        
        var dateComponents = DateComponents()
        dateComponents.month = -11
        
        let fromDate = Calendar.current.date(byAdding: dateComponents, to: tilDate)
        
        return dateFormatter.string(from: fromDate!)
    }
    
    func makeTillDateString(year: Int, month: Int, day: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let calendar = Calendar(identifier: .gregorian)
        
        let components = DateComponents(year: year, month: month, day: day)
        
        return dateFormatter.string(from: calendar.date(from: components)!)
    }
}
