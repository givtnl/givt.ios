//
//  ChangeAmountLimitRoutePreHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class ChangeAmountLimitRoutePreHandler : RequestPreProcessorWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R) throws -> Void) throws where R : RequestProtocol {
        let request = request as! ChangeAmountLimitRoute
        request.shouldGoToRegistation = !(LoginManager.shared.isFullyRegistered || !UserDefaults.standard.isTempUser)
        try completion(request as! R)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is ChangeAmountLimitRoute
    }
}

