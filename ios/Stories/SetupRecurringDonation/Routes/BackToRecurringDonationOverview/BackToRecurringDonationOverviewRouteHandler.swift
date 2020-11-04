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
        var validVc: SetupRecurringDonationOverviewViewController? = nil
        if let lastVc = context.navigationController?.viewControllers.last,
            let lastVcIndex = context.navigationController?.viewControllers.lastIndex(of: lastVc),
            lastVcIndex > 0,
            let vc = context.navigationController?.viewControllers[lastVcIndex-1] as? SetupRecurringDonationOverviewViewController {
            vc.reloadData = (request as! BackToRecurringDonationOverviewRoute).reloadData;
            validVc = vc
        }
        
        if let vc = validVc {
            context.navigationController?.popToViewController(vc, animated: true)
        }
        else {
            context.navigationController?.popToRootViewController(animated: true)
        }
        try completion(() as! R.TResponse)
    }
    
    func canHandle<R>(request: R) -> Bool where R : RequestProtocol {
        return request is BackToRecurringDonationOverviewRoute
    }
}
