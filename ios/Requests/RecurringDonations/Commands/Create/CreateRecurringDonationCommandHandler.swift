//
//  CreateRecurringDonationCommandHandler.swift
//  ios
//
//  Created by Mike Pattyn on 28/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CreateRecurringDonationCommandHandler : RequestHandlerProtocol {
    let apiClient = APIClient.cloud
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! CreateRecurringDonationCommand
        do {
            let body = try JSONEncoder().encode(request)
            try apiClient.post(url: "/recurringdonations", data: body) { response in
                if let resp = response {
                    if resp.isSuccess {
                        NotificationCenter.default.post(name: .GivtCreatedRecurringDonation, object: nil)
                    } else {
                        if resp.statusCode == 409 {
                            NotificationCenter.default.post(name: .GivtCreatedRecurringDonationDuplicate, object: nil)
                        }
                    }
                    try? completion(resp.isSuccess as! R.TResponse)
                } else {
                    try? completion(false as! R.TResponse)
                }
            }
        } catch {
            LogService.shared.info(message: "Unknown error")
            try? completion(false as! R.TResponse)
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is CreateRecurringDonationCommand
    }
}
