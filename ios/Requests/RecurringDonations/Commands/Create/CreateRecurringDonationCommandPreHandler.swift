//
//  CreateRecurringDonationCommandValidator.swift
//  ios
//
//  Created by Mike Pattyn on 28/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class CreateRecurringDonationCommandPreHandler: RequestPreProcessorProtocol {
    func handle<R>(request: R, completion: @escaping (R) throws -> Void) throws where R : RequestProtocol {
        let request = request as! CreateRecurringDonationCommand
        
        if let user = UserDefaults.standard.userExt {
            request.userId = UUID(uuidString: user.guid.uppercased())
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let startDate = dateFormatter.date(from: request.startDate) else {
            throw RecurringDonationError.wrongDate
        }
        
        request.cronExpression = buildCronExpression(startDate: startDate, frequency: request.frequency)
        
        try completion(request as! R)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is CreateRecurringDonationCommand
    }
    
    private func buildCronExpression(startDate: Date, frequency: Frequency) -> String {
        let cronExpression: String
        
        let dayOfMonth = startDate.getDay()
        let month = startDate.getMonth()

        switch frequency {
            case Frequency.Weekly:
                let dayOfWeek: String
                let myCalendar = Calendar(identifier: .gregorian)
                switch myCalendar.component(.weekday, from: startDate) {
                case 0, 7:
                    dayOfWeek = "SAT"
                case 1:
                    dayOfWeek = "SUN"
                case 2:
                    dayOfWeek = "MON"
                case 3:
                    dayOfWeek = "TUE"
                case 4:
                    dayOfWeek = "WED"
                case 5:
                    dayOfWeek = "THU"
                case 6:
                    dayOfWeek = "FRI"
                default:
                    dayOfWeek = "SUN"
                }
                cronExpression = "0 0 * * \(dayOfWeek)"
            case Frequency.Monthly:
                cronExpression = "0 0 \(dayOfMonth) * *"
            case Frequency.ThreeMonthly:
                cronExpression = "0 0 \(dayOfMonth) \(getFirstPartQuarterlyCronMonth(month: month))/3 *"
            case Frequency.SixMonthly:
                cronExpression = "0 0 \(dayOfMonth) \(getFirstPartHalfYearlyCronMonth(month: month))/6 *"
            case Frequency.Yearly:
                cronExpression = "0 0 \(dayOfMonth) \(month) *"
        }
        return cronExpression
    }
    private func getFirstPartQuarterlyCronMonth(month: Int) -> Int {
        switch month {
        case 0,3,6,9:
            return 1
        case 1,4,7,10:
            return 2
        case 2,5,8,11:
            return 3
        default:
            return 0
        }
    }
    private func getFirstPartHalfYearlyCronMonth(month: Int) -> Int {
        switch month {
        case 0,1,2,3,4,5:
            return month
        case 6,7,8,9,10,11:
            return month - 6
        default:
            return 0
        }
    }
}
