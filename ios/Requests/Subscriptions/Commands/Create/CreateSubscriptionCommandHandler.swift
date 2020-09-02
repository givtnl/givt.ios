//
//  CreateSubscriptionCommandHandler.swift
//  ios
//
//  Created by Mike Pattyn on 28/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CreateSubscriptionCommandHandler : RequestHandlerProtocol {
    let apiClient = CloudAPIClient.shared
    
    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! CreateSubscriptionCommand
        do {
            let body = try JSONEncoder().encode(request)
            try apiClient.post(url: "/subscriptions", data: body) { response in
                if let statusCode = response?.statusCode {
                    try? completion((statusCode == 201) as! R.TResponse)
                } else {
                    LogService.shared.info(message: "Couldnt get a response")
                    try? completion(false as! R.TResponse)
                }
            }
        } catch {
            LogService.shared.info(message: "Unknown error")
            try? completion(false as! R.TResponse)
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is CreateSubscriptionCommand
    }
}
