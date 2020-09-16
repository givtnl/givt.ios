//
//  BackToPreviousViewRouteHandler.swift
//  ios
//
//  Created by Jonas Brabant on 28/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import Foundation

class BackToRecurringDonationOverviewRouteHandler : RequestHandlerWithContextProtocol {
   
    public func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        context.navigationController?.popToRootViewController(animated: true)
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is BackToRecurringDonationOverviewRoute
    }
}
