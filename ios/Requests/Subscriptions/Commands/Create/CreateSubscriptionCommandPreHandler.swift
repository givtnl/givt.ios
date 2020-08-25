//
//  CreateSubscriptionCommandValidator.swift
//  ios
//
//  Created by Mike Pattyn on 28/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class CreateSubscriptionCommandPreHandler: RequestPreProcessorProtocol {
    func handle<R>(request: R, completion: @escaping (R) throws -> Void) throws where R : RequestProtocol {
        let request = request as! CreateSubscriptionCommand
        
        if let user = UserDefaults.standard.userExt {
            request.userId = UUID(uuidString: user.guid.uppercased())
        }
        try completion(request as! R)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is CreateSubscriptionCommand
    }
}
