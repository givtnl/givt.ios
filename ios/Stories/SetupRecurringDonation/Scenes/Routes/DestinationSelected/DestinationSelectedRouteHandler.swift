//
//  OpenChooseSubscriptionRouteHandler.swift
//  ios
//
//  Created by Mike Pattyn on 27/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

public class DestinationSelectedRouteHandler : RequestHandlerWithContextProtocol {
    public func handle<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) throws -> Void) throws where R : RequestProtocol {
        if let lastVc = context.navigationController?.viewControllers.last,
            let lastVcIndex = context.navigationController?.viewControllers.lastIndex(of: lastVc),
            lastVcIndex > 0,
            let vc = context.navigationController?.viewControllers[lastVcIndex-1] as? SetupRecurringDonationChooseSubscriptionViewController {
            vc.input = request as? DestinationSelectedRoute
        }
        context.navigationController?.popViewController(animated: true)
        try completion(() as! R.TResponse)
    }
      
    public func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is DestinationSelectedRoute
    }
}
