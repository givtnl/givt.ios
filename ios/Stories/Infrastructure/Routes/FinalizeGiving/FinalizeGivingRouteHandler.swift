//
//  FinalizeGivingRouteHandler.swift
//  ios
//
//  Created by Maarten Vergouwe on 22/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

class FinalizeGivingRouteHandler : RequestHandlerWithContextProtocol {
    func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        if let navController = context.navigationController {
            navController.navigationBar.isHidden = false
            navController.popToRootViewController(animated: true)
            navController.topViewController?.dismiss(animated: false) {
                try! completion(() as! R.TResponse)
            }
        }
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is FinalizeGivingRoute
    }
}
