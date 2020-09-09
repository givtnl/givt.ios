//
//  CreateRecurringDonationCommandPostHandler.swift
//  ios
//
//  Created by Mike Pattyn on 09/09/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class CreateRecurringDonationCommandPostHandler: RequestPostProcessorProtocol {
    func handle<R>(request: R, response: R.TResponse, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        
        let request = request as! CreateRecurringDonationCommand
        
        NotificationCenter.default.post(name: .GivtCreatedRecurringDonation, object: nil, userInfo: ["recurringDonationId":request.recurringDonationId?.uuidString])
    }

    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is CreateRecurringDonationCommand
    }
}
