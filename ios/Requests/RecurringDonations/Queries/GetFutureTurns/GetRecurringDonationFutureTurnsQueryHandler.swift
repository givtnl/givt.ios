//
//  GetRecurringDonationFutureTurnsQueryHandler.swift
//  ios
//
//  Created by Mike Pattyn on 15/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import SwifCron

class GetRecurringDonationFutureTurnsQueryHandler : RequestHandlerProtocol {
    
    private var donations: [RecurringDonationTurnViewModel] = []
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let query = request as! GetRecurringDonationFutureTurnsQuery
        
        guard let lastDonationDate: Date = query.recurringDonationLastTurn.Timestamp.toDate else {
            return
        }
        guard let cronObject: SwifCron = createSwifCron(cronString: query.recurringDonation.cronExpression) else {
            return
        }
        
        var nextRunDate = try cronObject.next(from: lastDonationDate)
        
        let currentDay: String = nextRunDate.getDay().string
        let currentMonth: String = nextRunDate.getMonthName()
        let currentYear: String = nextRunDate.getYear().string
        
        let model = RecurringDonationTurnViewModel(amount: Decimal(query.recurringDonation.amountPerTurn), day: currentDay, month: currentMonth, year: currentYear, status: 0)
        
        donations.append(model)
        
        print(nextRunDate)
        
        let turnsToCalculate = query.recurringDonation.endsAfterTurns-query.recurringDonationPastTurnsCount
        
        if turnsToCalculate > 1 {
            for _ in 1...turnsToCalculate - 1 {
                let prevRunDate = nextRunDate
                
                nextRunDate = try cronObject.next(from: prevRunDate)
                
                let currentDay: String = nextRunDate.getDay().string
                let currentMonth: String = nextRunDate.getMonthName()
                let currentYear: String = nextRunDate.getYear().string
                
                let model = RecurringDonationTurnViewModel(amount: Decimal(query.recurringDonation.amountPerTurn), day: currentDay, month: currentMonth, year: currentYear, status: 0)
                
                donations.append(model)
                
                print(nextRunDate)
            }
        }
        try completion(donations as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is GetRecurringDonationFutureTurnsQuery
    }
    fileprivate func createSwifCron(cronString: String) -> SwifCron? {
        do {
            let cronItems: [String] = transformDayInCronToInt(cronArray: cronString.split(separator: " ").map(String.init))
            return try SwifCron(cronItems.joined(separator: " "))
        }
        catch {
            print(error)
            return nil
        }
    }
    fileprivate func transformDayInCronToInt(cronArray: [String]) -> [String] {
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
            day = "7"
        default:
            day = "*"
        }
        
        newarray[4] = day
        return newarray
    }
    
    fileprivate func returnStringFromDayInteger(value: Int) -> String {
        var retVal: String
        switch value {
        case 1:
            retVal = "SUN"
        case 2:
            retVal = "MON"
        case 3:
            retVal = "TUE"
        case 4:
            retVal = "WED"
        case 5:
            retVal = "THU"
        case 6:
            retVal = "FRI"
        case 7:
            retVal = "SAT"
        default:
            retVal = "*"
        }
        return retVal
    }
}
