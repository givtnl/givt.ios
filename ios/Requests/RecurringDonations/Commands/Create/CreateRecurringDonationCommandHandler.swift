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
                if let success = response?.isSuccess {
                    try? completion(ResponseModel(result: success) as! R.TResponse)
                } else {
                    switch response?.status {
                    case .unauthorized :
                        try? completion(ResponseModel(result: false, error: .unauthorized) as! R.TResponse)
                        break
                    case .conflict :
                        try? completion(ResponseModel(result: false, error: .duplicate) as! R.TResponse)
                        break
                    default :
                        try? completion(ResponseModel(result: false, error: .unknown) as! R.TResponse)
                    }
                }
            }
        } catch {
            LogService.shared.info(message: "Unknown error")
            try? completion(ResponseModel(result: false, error: .unknown) as! R.TResponse)
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is CreateRecurringDonationCommand
    }
}
