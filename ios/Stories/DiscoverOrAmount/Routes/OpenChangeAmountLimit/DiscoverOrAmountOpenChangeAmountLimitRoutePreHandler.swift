//
//  DiscoverOrAmountOpenChangeAmountLimitRoutePreHandler.swift
//  ios
//
//  Created by Mike Pattyn on 29/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import Foundation

class DiscoverOrAmountOpenChangeAmountLimitRoutePreHandler : RequestPreProcessorWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R) throws -> Void) throws where R : RequestProtocol {
        let request = request as! DiscoverOrAmountOpenChangeAmountLimitRoute
        request.shouldGoToRegistation = !(LoginManager.shared.isFullyRegistered || !UserDefaults.standard.isTempUser)
        try completion(request as! R)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is DiscoverOrAmountOpenChangeAmountLimitRoute
    }
}

