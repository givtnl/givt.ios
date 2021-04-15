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
        
        let cronMonth = command.date.getMonth()
        let cronDay = command.date.getDay()
                
        switch command.frequency {
            case .Once:
                command.cronExpression = nil
            case .Monthly:
                command.cronExpression = "0 0 \(cronDay) \(cronMonth)/1 *"
            case .Quarterly:
                command.cronExpression = "0 0 \(cronDay) \(cronMonth)/3 *"
            case .HalfYearly:
                command.cronExpression = "0 0 \(cronDay) \(cronMonth)/6 *"
            case .Yearly:
                command.cronExpression = "0 0 \(cronDay) \(cronMonth)/12 *"
        }
        
        try completion(command as! R)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is CreateExternalDonationCommand
    }
}
