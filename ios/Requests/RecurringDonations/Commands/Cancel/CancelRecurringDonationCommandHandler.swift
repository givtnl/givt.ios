//
//  CancelRecurringDonationCommandHandler.swift
//  ios
//
//  Created by Mike Pattyn on 07/09/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
class CancelRecurringDonationCommandHandler : RequestHandlerProtocol {
    let apiClient = APIClient.cloud
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! CancelRecurringDonationCommand
        apiClient.patch(url: "/recurringdonations/"+request.recurringDonationId+"/cancel") { response in
            if let success = response?.isSuccess {
                try? completion(success as! R.TResponse)
            } else {
                try? completion(false as! R.TResponse)
            }
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is CancelRecurringDonationCommand
    }
}
