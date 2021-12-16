//
//  CreateExternalDonationCommandCronGenerator.swift
//  ios
//
//  Created by Mike Pattyn on 23/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class CreateExternalDonationCronGenerator: RequestPreProcessorProtocol {
    func handle<R>(request: R, completion: @escaping (R) throws -> Void) throws where R : RequestProtocol {
        let command = request as! CreateExternalDonationCommand
        
        command.cronExpression = buildCronExpression(startDate: command.date, frequency: command.frequency)
        
        try completion(command as! R)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is CreateExternalDonationCommand
    }
    
    private func buildCronExpression(startDate: Date, frequency: ExternalDonationFrequency) -> String? {
        let cronExpression: String?
        
        let dayOfMonth = startDate.getDay()
        let month = startDate.getMonth()

        switch frequency {
            case ExternalDonationFrequency.Monthly:
                cronExpression = "0 0 \(dayOfMonth) * *"
            case ExternalDonationFrequency.Quarterly:
                cronExpression = "0 0 \(dayOfMonth) \(getFirstPartQuarterlyCronMonth(month: month))/3 *"
            case ExternalDonationFrequency.HalfYearly:
                cronExpression = "0 0 \(dayOfMonth) \(getFirstPartHalfYearlyCronMonth(month: month))/6 *"
            case ExternalDonationFrequency.Yearly:
                cronExpression = "0 0 \(dayOfMonth) \(month) *"
            default:
                cronExpression = nil
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
