//
//  CreateDonationCommandValidator.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class CreateDonationCommandValidator: RequestPreProcessorProtocol {
    func handle<R>(request: R, completion: @escaping (R) throws -> Void) throws where R : RequestProtocol {
        let request = request as! CreateDonationCommand
        let amountLimit = UserDefaults.standard.amountLimit
        
        if request.amount > Decimal(amountLimit) {
            throw DonationError.amountTooHigh
        }
        
        if request.amount < GivtManager.shared.minimumAmount {
            throw DonationError.amountTooLow
        }
        
        try completion(request as! R)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is CreateDonationCommand
    }
}
