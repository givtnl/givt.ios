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
    let apiClient = APIClient.shared

    func handle<R>(request: R, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        let request = request as! CreateSubscriptionCommand
        do {
            let body = try request.jsonData()
            try apiClient.postToCloudAPI(url: "https://api.development.givtapp.net/subscriptions", data: body, callback: { response in
                if let responseType = response?.statusCode {
                    switch(responseType) {
                        case 202:
                            LogService.shared.info(message: "Succesfully posted a new subscription")
                        default:
                            LogService.shared.info(message: "Got a response but was not accepted with status code: "  + String(responseType))
                    }
                } else {
                    LogService.shared.info(message: "Couldnt get a response")
                }
            })
        } catch {
            LogService.shared.info(message: "Unknown error")
        }
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        request is CreateSubscriptionCommand
    }
}
